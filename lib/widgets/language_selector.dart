import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yaumian_app/l10n/app_localizations.dart';
import '../providers/locale_provider.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLocale = localeProvider.locale.languageCode;

    return ListTile(
      leading: const Icon(Icons.language),
      title: Text(AppLocalizations.of(context)!.language),
      subtitle: Text(
        currentLocale == 'id' ? 'Bahasa Indonesia' : 'English',
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      trailing: DropdownButton<String>(
        value: currentLocale,
        items: [
          DropdownMenuItem(
            value: 'id',
            child: Text(
              'Bahasa Indonesia',
              style: TextStyle(
                color: currentLocale == 'id' ? Theme.of(context).colorScheme.primary : null,
              ),
            ),
          ),
          DropdownMenuItem(
            value: 'en',
            child: Text(
              'English',
              style: TextStyle(
                color: currentLocale == 'en' ? Theme.of(context).colorScheme.primary : null,
              ),
            ),
          ),
        ],
        onChanged: (String? value) {
          if (value != null) {
            localeProvider.setLocale(Locale(value));
          }
        },
      ),
    );
  }
}
