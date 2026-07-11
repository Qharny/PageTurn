import 'package:flutter/material.dart';

import '../../data/models/book_model.dart';
import '../../routes.dart';
import '../../theme.dart';
import '../common/widgets/book_cover.dart';
import 'search_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _provider = SearchProvider();
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _provider.loadMore();
      }
    });
  }

  @override
  void dispose() {
    _provider.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.neutral,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFF2ECE4), width: 1.2),
                      ),
                      child: const Icon(Icons.arrow_back_rounded, color: Color(0xFF5C3826), size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.search,
                      onSubmitted: _provider.search,
                      decoration: InputDecoration(
                        hintText: 'Search Project Gutenberg\'s free ebooks…',
                        hintStyle: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Color(0xFF7A6B63)),
                        prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF7A6B63), size: 20),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFFE2DDD5)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListenableBuilder(
                listenable: _provider,
                builder: (context, _) => _buildBody(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_provider.status) {
      case SearchStatus.idle:
        return const Center(
          child: Text('Search thousands of free public-domain ebooks.',
              style: TextStyle(fontFamily: 'Inter', color: Color(0xFF7A6B63), fontSize: 13)),
        );
      case SearchStatus.loading:
        return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
      case SearchStatus.error:
        return Center(
          child: Text(_provider.errorMessage ?? 'Something went wrong.',
              style: const TextStyle(fontFamily: 'Inter', color: Color(0xFF7A6B63), fontSize: 13)),
        );
      case SearchStatus.empty:
        return const Center(
          child: Text('No books found. Try another search.',
              style: TextStyle(fontFamily: 'Inter', color: Color(0xFF7A6B63), fontSize: 13)),
        );
      case SearchStatus.ready:
      case SearchStatus.loadingMore:
        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          itemCount: _provider.results.length + (_provider.status == SearchStatus.loadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= _provider.results.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
              );
            }
            return _buildResultTile(_provider.results[index]);
          },
        );
    }
  }

  Widget _buildResultTile(Book book) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.details, arguments: book),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF2ECE4), width: 1.2),
        ),
        child: Row(
          children: [
            BookCover(coverAsset: book.coverAsset, coverUrl: book.coverUrl, title: book.title, width: 48, height: 68),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(book.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 3),
                  Text(book.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: Color(0xFF7A6B63))),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF7A6B63)),
          ],
        ),
      ),
    );
  }
}
