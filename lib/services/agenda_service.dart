import '../models/agenda.dart';
import 'api_service.dart';

class AgendaService {
  final ApiService _apiService;

  AgendaService(this._apiService);

  Future<List<Agenda>> getAgendas() async {
    try {
      print('📅 Fetching agendas...');
      final response = await _apiService.get('/api/agenda', requiresAuth: true);
      
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> agendaList = response['data'];
        return agendaList.map((json) => Agenda.fromJson(json)).toList();
      }
      
      // Handle forbidden error
      if (response['success'] == false && response['message'] != null) {
        if (response['message'].toString().contains('Forbidden') || 
            response['message'].toString().contains('insufficient privileges')) {
          throw Exception('Anda tidak memiliki akses ke fitur Agenda. Silakan hubungi admin.');
        }
        throw Exception(response['message']);
      }
      
      return [];
    } catch (e) {
      print('❌ Error fetching agendas: $e');
      rethrow;
    }
  }

  Future<Agenda?> getAgendaById(int id) async {
    try {
      final response = await _apiService.get('/api/agenda/$id', requiresAuth: true);
      
      if (response['success'] == true && response['data'] != null) {
        return Agenda.fromJson(response['data']);
      }
      
      return null;
    } catch (e) {
      print('❌ Error fetching agenda detail: $e');
      rethrow;
    }
  }
}
