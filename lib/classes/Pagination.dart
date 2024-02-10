import 'package:flutter/material.dart';
class Pagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;

  Pagination({
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    List<int> visiblePages = List<int>.generate(totalPages, (index) => index + 1);
    if (totalPages > 4) {
      if (currentPage > 2) {
        visiblePages = visiblePages.skip(currentPage - 3).toList();
      }
      if (visiblePages.length > 4) {
        visiblePages = visiblePages.take(4).toList();
        visiblePages.add(-1); // Add ellipsis
        visiblePages.add(totalPages); // Add last page
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
          icon: Icon(Icons.arrow_back),
        ),
        SizedBox(width: 20),
        ...visiblePages.map((page) {
          if (page == -1) {
            return Text('...');
          }
          return TextButton(
            onPressed: () => onPageChanged(page),
            child: Text(
              '$page',
              style: TextStyle(
                fontWeight: page == currentPage ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
        SizedBox(width: 20),
        IconButton(
          onPressed: currentPage < totalPages ? () => onPageChanged(currentPage + 1) : null,
          icon: Icon(Icons.arrow_forward),
        ),
      ],
    );
  }
}
