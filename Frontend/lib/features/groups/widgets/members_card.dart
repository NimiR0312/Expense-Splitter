import 'package:flutter/material.dart';

import 'package:expense_splitter/core/theme/app_spacing.dart';
import 'package:expense_splitter/core/widgets/common/app_card.dart';
import 'package:expense_splitter/core/widgets/common/section_header.dart';

import 'package:expense_splitter/features/groups/models/group_model.dart';
import 'package:expense_splitter/features/groups/widgets/member_tile.dart';

class MembersCard extends StatelessWidget {
  final Group group;

  const MembersCard({
    super.key,
    required this.group,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: "Members (${group.members.length})",
          ),

          const SizedBox(
            height: AppSpacing.md,
          ),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: group.members.length,

            separatorBuilder: (_, __) => const Divider(),

            itemBuilder: (context, index) {
              return MemberTile(
                member: group.members[index],
              );
            },
          ),
        ],
      ),
    );
  }
}