import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/presentation/fasting_type_text.dart';
import 'package:fasomo/features/duas/domain/entities/dua.dart';
import 'package:fasomo/features/duas/presentation/bloc/duas_bloc.dart';
import 'package:fasomo/features/duas/presentation/dua_text.dart';
import 'package:fasomo/features/duas/presentation/widgets/dua_card.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The bundled duas and hadith, grouped by section, with a filter for one
/// kind of fast. Expects a [DuasBloc] above it.
class DuasPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).duasTitle)),
      body: BlocBuilder<DuasBloc, DuasState>(
        builder: (context, state) => Column(
          children: [
            _FilterBar(selected: state.filter),
            Expanded(child: _DuaList(sections: state.sections)),
          ],
        ),
      ),
    );
  }
}

/// "All" and one chip per kind of fast.
class _FilterBar extends StatelessWidget {
  const new({required this.selected});

  final FastingType? selected;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final bloc = context.read<DuasBloc>();
    final filters = <(FastingType?, String)>[
      (null, localization.duasFilterAll),
      for (final type in FastingType.values)
        (type, localization.fastingTypeTitle(type)),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          for (final (type, label) in filters)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: ChoiceChip(
                label: Text(label),
                selected: selected == type,
                onSelected: (_) => bloc.add(DuasFilterChanged(type)),
              ),
            ),
        ],
      ),
    );
  }
}

class _DuaList extends StatelessWidget {
  const new({required this.sections});

  final List<DuaSection> sections;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 24),
      children: [
        for (final section in sections) ...[
          Padding(
            padding: const EdgeInsetsDirectional.only(top: 8, bottom: 12),
            child: Semantics(
              header: true,
              child: Text(
                localization.duaSectionTitle(section.category),
                style: theme.textTheme.titleLarge,
              ),
            ),
          ),
          for (final Dua dua in section.duas) DuaCard(dua: dua),
        ],
      ],
    );
  }
}
