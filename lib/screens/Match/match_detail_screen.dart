import 'package:flutter/material.dart';
import '../../models/Match/match_detail_dto.dart';
import 'package:uadd_app/models/Match/match_dto.dart';
import '../../services/match_service.dart';

class MatchDetailScreen extends StatefulWidget {
  final int matchId;
  final MatchDto match;

  const MatchDetailScreen({
    super.key,
    required this.matchId,
    required this.match,
  });

  @override
  State<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen> {
  final _matchService = MatchService();
  late Future<MatchDetailDto> _futureMatch;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMatch();
  }

  void _loadMatch() {
    setState(() {
      _futureMatch = _matchService.getMatchById(widget.matchId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.surface.withOpacity(0.7),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_back,
              color: colorScheme.onSurface,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                child: const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: FutureBuilder<MatchDetailDto>(
        future: _futureMatch,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load match',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.tonal(
                    onPressed: _loadMatch,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return Center(
              child: Text(
                'Match not found',
                style: theme.textTheme.titleMedium,
              ),
            );
          }

          final match = snapshot.data!;

          return CustomScrollView(
            slivers: [
              // Header with image
              SliverAppBar(
                expandedHeight: 250,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        match.imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: colorScheme.surfaceVariant,
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: colorScheme.surfaceVariant,
                          child: Center(
                            child: Icon(
                              Icons.sports_soccer,
                              size: 60,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                      // Gradient overlay
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Match title and date
                      Text(
                        match.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(match.matchDate),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Teams vs card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Team A (Visitor)
                            _buildTeamRow(
                              context,
                              teamName: match.teamA,
                              isVisitor: true,
                            ),
                            const SizedBox(height: 16),
                            // VS separator
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                'VS',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Team B (Home)
                            _buildTeamRow(
                              context,
                              teamName: match.teamB,
                              isVisitor: false,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Match info cards
                      _buildInfoCard(
                        context,
                        icon: Icons.location_on,
                        title: 'Location',
                        value: match.location,
                      ),
                      const SizedBox(height: 16),
                      _buildInfoCard(
                        context,
                        icon: Icons.sports,
                        title: 'Sport',
                        value: match.sportType,
                      ),
                      const SizedBox(height: 16),
                      _buildInfoCard(
                        context,
                        icon: Icons.gamepad,
                        title: 'Plantilla Equipo A',
                        value: match.descriptionA,
                      ),
                      _buildInfoCard(
                        context,
                        icon: Icons.gamepad,
                        title: 'Plantilla Equipo B',
                        value: match.descriptionB,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTeamRow(BuildContext context, {required String teamName, required bool isVisitor}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.people,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isVisitor ? 'Visitor Team' : 'Home Team',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              Text(
                teamName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isVisitor 
                ? Colors.orange.withOpacity(0.2) 
                : Colors.green.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            isVisitor ? 'Visitor' : 'Home',
            style: theme.textTheme.labelSmall?.copyWith(
              color: isVisitor ? Colors.orange : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 20,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    
    return '$day/$month/${date.year} • $hour:$minute';
  }
}