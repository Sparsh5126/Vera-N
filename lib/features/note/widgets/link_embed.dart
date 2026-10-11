import 'package:flutter/material.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/storage/files/web_link.dart';
import '../../../core/styles/app_styles.dart';

/// A web link inside the note, in place of its line: the title, the
/// description when the sharing app sent one, and the site. Tapping it
/// opens the link in the browser. Everything shown was written in the
/// note; nothing is fetched.
class LinkEmbed extends StatelessWidget {
  const LinkEmbed({super.key, required this.link, required this.onOpen});

  final WebLink link;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;
    final description = link.description;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: AppSize.linkCardWidth),
      child: SizedBox(
        width: double.infinity,
        child: Semantics(
          button: true,
          label: AppCopy.openLink(link.label),
          excludeSemantics: true,
          child: Material(
            color: colors.card,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.cardBorder,
              side: BorderSide(color: colors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onOpen,
              child: Padding(
                padding: AppSpace.card,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      link.label,
                      style: styles.cardTitle,
                      maxLines: AppSize.linkTitleLines,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (description != null) ...[
                      const SizedBox(height: AppSpace.xs),
                      Text(
                        description,
                        style: styles.card.copyWith(
                          color: colors.textSecondary,
                        ),
                        maxLines: AppSize.linkDescriptionLines,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: AppSpace.s),
                    _SiteRow(site: link.site),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The site, with a mark that the card opens outside the app.
class _SiteRow extends StatelessWidget {
  const _SiteRow({required this.site});

  final String site;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Icon(Icons.link, size: AppSize.iconSmall, color: colors.textSecondary),
        const SizedBox(width: AppSpace.xs),
        Expanded(
          child: Text(
            site,
            style: context.textStyles.small,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Icon(
          Icons.open_in_new,
          size: AppSize.iconSmall,
          color: colors.textSecondary,
        ),
      ],
    );
  }
}
