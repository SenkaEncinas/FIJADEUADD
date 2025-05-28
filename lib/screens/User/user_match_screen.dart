import 'package:flutter/material.dart';
import 'package:uadd_app/models/Match/match_dto.dart';
import 'package:uadd_app/screens/User/user_home_screen.dart';
import '../../services/match_service.dart';
import '../login_screen.dart';
import 'user_event_screen.dart';

class UserMatchScreen extends StatefulWidget {
  const UserMatchScreen({super.key});

  @override
  State<UserMatchScreen> createState() => _UserMatchScreenState();
}

class _UserMatchScreenState extends State<UserMatchScreen> {
  final _matchService = MatchService();
  late Future<List<MatchDto>> _futureMatches;
  List<MatchDto> _filteredMatches = [];
  final TextEditingController _searchController = TextEditingController();
  String _selectedSport = 'Todos';
  final List<String> _sports = [
    'Todos',
    'Fútbol',
    'Baloncesto',
    'Tenis',
    'Voleibol',
    'Béisbol',
  ];

  @override
  void initState() {
    super.initState();
    _futureMatches = _loadMatches();
    _searchController.addListener(_filterMatches);
  }

  Future<List<MatchDto>> _loadMatches() async {
    try {
      final matches = await _matchService.getAllMatchs();
      _filteredMatches = matches;
      return matches;
    } catch (e) {
      debugPrint('Error loading matches: $e'); 
      _filteredMatches = [];
      return [];
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshMatches() async {
    setState(() {
      _futureMatches = _loadMatches();
    });
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _filterMatches() {
    _futureMatches.then((matches) {
      if (matches.isEmpty) return;
      
      setState(() {
        _filteredMatches = matches.where((match) {
          final matchesSearch = _searchController.text.isEmpty || 
              match.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
              match.teamA.toLowerCase().contains(_searchController.text.toLowerCase()) ||
              match.teamB.toLowerCase().contains(_searchController.text.toLowerCase());
          final matchesSport = _selectedSport == 'Todos' || 
              (match.sportType == _selectedSport);
          return matchesSearch && matchesSport;
        }).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).copyWith(
      primaryColor: const Color(0xFF2E7D32),
      colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: const Color(0xFF2E7D32),
            secondary: const Color(0xFF81C784),
          ),
    );

    return Theme(
      data: theme,
      child: Scaffold(
        drawer: _buildDrawer(theme),
        appBar: _buildAppBar(theme),
        body: _buildBody(theme),
      ),
    );
  }

  Widget _buildDrawer(ThemeData theme) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: theme.primaryColor,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Menú de Navegación',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Selecciona una opción',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'FUNCIONALIDADES',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.paid, color: theme.primaryColor),
            title: const Text('Ventas'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UserHomeScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.event, color: theme.primaryColor),
            title: const Text('Eventos'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UserEventScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.people, color: theme.primaryColor),
            title: const Text('Matches'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: theme.primaryColor),
            title: const Text('Cerrar Sesión'),
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      title: const Text('Partidos',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 20)),
      centerTitle: true,
      backgroundColor: theme.primaryColor,
      elevation: 5,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(15),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: _refreshMatches,
          tooltip: 'Actualizar',
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: _logout,
          tooltip: 'Cerrar sesión',
        ),
      ],
    );
  }

  Widget _buildBody(ThemeData theme) {
    return RefreshIndicator(
      onRefresh: _refreshMatches,
      color: theme.primaryColor,
      child: FutureBuilder<List<MatchDto>>(
        future: _futureMatches,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
              ),
            );
          }

          if (snapshot.hasError) {
            return _buildErrorWidget(theme);
          }

          return Column(
            children: [
              _buildSearchFilters(theme),
              _buildMatchesList(theme),
            ],
          );
        },
      ),
    );
  }

  Widget _buildErrorWidget(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: theme.primaryColor),
          const SizedBox(height: 16),
          Text('Error al cargar partidos',
              style: TextStyle(fontSize: 16, color: theme.primaryColor)),
          const SizedBox(height: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _refreshMatches,
            child: const Text('Reintentar',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchFilters(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          )
        ],
        border: Border.all(
          color: theme.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 30,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                hintText: 'Buscar partidos...',
                prefixIcon: Icon(Icons.search, size: 20, color: theme.primaryColor),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: theme.primaryColor, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: theme.primaryColor, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: theme.primaryColor, width: 1.5),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 30,
            child: DropdownButtonFormField<String>(
              isDense: true,
              value: _selectedSport,
              dropdownColor: Colors.white,
              icon: Icon(Icons.arrow_drop_down, size: 20, color: theme.primaryColor),
              items: _sports.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, 
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.primaryColor
                    ),
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedSport = newValue!;
                  _filterMatches();
                });
              },
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                labelText: 'Deporte',
                labelStyle: TextStyle(
                  fontSize: 12,
                  color: theme.primaryColor
                ),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: theme.primaryColor, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: theme.primaryColor, width: 1),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchesList(ThemeData theme) {
    return Expanded(
      child: _filteredMatches.isEmpty
          ? _buildNoResultsWidget(theme)
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _filteredMatches.length,
              itemBuilder: (context, index) {
                final match = _filteredMatches[index];
                return _buildMatchCard(theme, match);
              },
            ),
    );
  }

  Widget _buildNoResultsWidget(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 48, color: theme.primaryColor),
          const SizedBox(height: 16),
          Text('No se encontraron partidos',
              style: TextStyle(fontSize: 16, color: theme.primaryColor)),
          const SizedBox(height: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              setState(() {
                _searchController.clear();
                _selectedSport = 'Todos';
                _filterMatches();
              });
            },
            child: const Text('Limpiar filtros',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchCard(ThemeData theme, MatchDto match) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: theme.primaryColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          // Navegar a pantalla de detalle del partido
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15)),
              child: Stack(
                children: [
                  _buildMatchImage(theme, match),
                  _buildMatchDateBadge(match),
                ],
              ),
            ),
            _buildMatchDetails(theme, match),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchImage(ThemeData theme, MatchDto match) {
    return Image.network(
      match.imageUrl,
      height: 200,
      width: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded / 
                    loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => Container(
        height: 200,
        color: Colors.grey[200],
        child: Center(
          child: Icon(
            _getSportIcon(match.sportType),
            size: 50,
            color: theme.primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildMatchDateBadge(MatchDto match) {
    return Positioned(
      bottom: 10,
      left: 10,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '${match.matchDate.day}/${match.matchDate.month}/${match.matchDate.year}',
          style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildMatchDetails(ThemeData theme, MatchDto match) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            match.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          
          // Equipos enfrentados
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text(
                    match.teamA,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Chip(
                    label: const Text('Local'),
                    backgroundColor: theme.primaryColor.withOpacity(0.1),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  'VS',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Column(
                children: [
                  Text(
                    match.teamB,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Chip(
                    label: Text('Visitante'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Detalles adicionales
          Row(
            children: [
              Icon(Icons.location_on,
                  size: 16, color: theme.primaryColor),
              const SizedBox(width: 4),
              Text(
                match.location,
                style: TextStyle(
                  color: theme.primaryColor,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Icon(Icons.sports,
                  size: 16, color: theme.primaryColor),
              const SizedBox(width: 4),
              Text(
                match.sportType,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.access_time,
                  size: 16, color: theme.primaryColor),
              const SizedBox(width: 4),
              Text(
                '${match.matchDate.hour}:${match.matchDate.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getSportIcon(String sportType) {
    switch (sportType.toLowerCase()) {
      case 'fútbol':
      case 'futbol':
        return Icons.sports_soccer;
      case 'baloncesto':
      case 'básquetbol':
        return Icons.sports_basketball;
      case 'tenis':
        return Icons.sports_tennis;
      case 'voleibol':
        return Icons.sports_volleyball;
      default:
        return Icons.sports;
    }
  }
}