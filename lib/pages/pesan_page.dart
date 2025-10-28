import 'package:flutter/material.dart';

class PesanPage extends StatelessWidget {
  const PesanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: const Text('Kader A'),
            subtitle: const Text('Selamat pagi, apa kabar?'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('09:30', style: TextStyle(fontSize: 12)),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('2', style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ],
            ),
            onTap: () {},
          ),
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: const Text('Kader B'),
            subtitle: const Text('Terima kasih atas informasinya.'),
            trailing: const Text('08:15', style: TextStyle(fontSize: 12)),
            onTap: () {},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.red,
        child: const Icon(Icons.chat),
      ),
    );
  }
}
