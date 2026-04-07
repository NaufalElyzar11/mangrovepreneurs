import 'package:flutter/material.dart';
import '../widgets/team_member_card.dart';
import '../core/theme/mangrove_theme.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          _buildLogoSection(context),
          
          const SizedBox(height: 16),
          
          _buildProjectDescriptionSection(context),
          
          const SizedBox(height: 24),
          
          const TeamSectionHeader(
            title: 'Mangrovepreneurs Team',
            icon: Icons.eco_outlined,
            imagePath: 'assets/images/logo.jpeg',
          ),
          
          const TeamMemberCard(
            name: 'M. Baihaqi',
            role: 'Team Leader',
            imagePath: 'assets/images/ubay.jpeg',
            avatarIcon: Icons.nature_people_outlined,
            avatarColor: MangroveTheme.oliveGreen,
          ),
          const TeamMemberCard(
            name: 'Luthfi Nor Anshori',
            role: 'Bee Specialist',
            imagePath: 'assets/images/upi.jpeg',
            avatarIcon: Icons.pest_control_outlined,
            avatarColor: MangroveTheme.mutedBrown,
          ),
          const TeamMemberCard(
            name: 'Rezky Amalia',
            role: 'Field Researcher',
            imagePath: 'assets/images/ka.jpeg',
            avatarIcon: Icons.explore_outlined,
            avatarColor: MangroveTheme.primaryGreen,
          ),
          
          const SizedBox(height: 16),
          
          const TeamSectionHeader(
            title: 'NRN Project Team',
            icon: Icons.memory_outlined,
          ),
          
          const TeamMemberCard(
            name: 'Siti Fathimah Azzahra',
            role: 'IoT Engineer',
            imagePath: 'assets/images/Rr.PNG',
            avatarIcon: Icons.developer_board_outlined,
            avatarColor: MangroveTheme.primaryGreen,
          ),
          const TeamMemberCard(
            name: 'Nanda Ikbar',
            role: 'Electrical & Mechanical Engineer',
            imagePath: 'assets/images/Nanda.jpg',
            avatarIcon: Icons.electrical_services_outlined,
            avatarColor: MangroveTheme.oliveGreen,
          ),
          const TeamMemberCard(
            name: 'Naufal Elyzar',
            role: 'Software Engineer',
            imagePath: 'assets/images/Naufal2.jpg',
            avatarIcon: Icons.code_outlined,
            avatarColor: MangroveTheme.mutedBrown,
          ),
          
          const SizedBox(height: 24),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Mangrovepreneurs App v1.0.0',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: MangroveTheme.textHint,
              ),
            ),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }
  
  Widget _buildLogoSection(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: MangroveTheme.primaryGreen.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/images/logo.jpeg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Mangrovepreneurs',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: MangroveTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Madu Kelulut Monitoring',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: MangroveTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProjectDescriptionSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: MangroveTheme.primaryGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.info_outline,
                      color: MangroveTheme.primaryGreen,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'Project Description',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              _buildDescriptionItem(
                context,
                title: 'Kalulut (Stingless Bee)',
                icon: Icons.hive_outlined,
                description: 
                  'Kalulut, also known as kelulut or stingless bees (Trigona sp.), are native bees '
                  'found throughout Southeast Asia. They produce unique honey with distinctive '
                  'medicinal properties. Unlike honeybees, kalulut are stingless and are crucial '
                  'pollinators in forest ecosystems.',
              ),
              
              const Divider(height: 32),
              
              _buildDescriptionItem(
                context,
                title: 'Mangrove Ecosystem',
                icon: Icons.park_outlined,
                description:
                  'Mangrove forests are coastal ecosystems where trees and shrubs thrive in '
                  'tidal salt water. They provide critical habitats for various species, protect '
                  'coastlines from erosion, and serve as carbon sinks. Kalulut populations in '
                  'mangroves contribute to ecosystem health through pollination.',
              ),
              
              const Divider(height: 32),
              
              _buildDescriptionItem(
                context,
                title: 'Monitoring Purpose',
                icon: Icons.monitor_heart_outlined,
                description:
                  'This IoT monitoring system tracks hive conditions including temperature, '
                  'humidity, and weight. Monitoring helps beekeepers understand colony health, '
                  'detect honey harvesting opportunities, and identify potential issues early. '
                  'Data-driven insights support sustainable beekeeping practices.',
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildDescriptionItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String description,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: MangroveTheme.oliveGreen,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: MangroveTheme.oliveGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
