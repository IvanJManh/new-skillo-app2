import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final String userName;
  final String userEmail;

  const ProfilePage({
    super.key,
    required this.userName,
    required this.userEmail,
  });

    @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _notificationEnabled = true;
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        flexibleSpace: SafeArea(
          child: Align(
            alignment: AlignmentGeometry.bottomCenter,
            child: Text(
              'Profile',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 25),
          child: Column(
            children: [
              _profileCard(),
              SizedBox(height: 20),
              _accountInfo(),
              SizedBox(height: 20),
              _settings(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 10,
            offset: Offset(1, 8),
          ),
        ],
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        border: Border.all(color: Color.fromARGB(255, 71, 172, 200)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 42,
            backgroundImage: AssetImage('lib/images/profile.png'),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.userName,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
            
                Text(
                  widget.userEmail,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2
                ),
                
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _accountInfo() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 10,
            offset: Offset(1, 8),
          ),
        ],
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        border: Border.all(color: Color.fromARGB(255, 71, 172, 200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Info',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          ListTile(
            title: Text('Name'),
            subtitle: Text(widget.userName),
          ),
          ListTile(
            title: Text('Email'),
            subtitle: Text(widget.userEmail),
          ),
          ListTile(
            title: Text('Phone'),
            subtitle: Text('+7767566562'),
          ),
        ],
      ),
    );
  }

  Widget _settings() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 10,
            offset: Offset(1, 8),
          ),
        ],
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        border: Border.all(color: Color.fromARGB(255, 71, 172, 200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          ListTile(
            title: Text('Notification'),
            trailing: Switch(
              value: _notificationEnabled, 
              onChanged: (value) {
                setState(() {
                  _notificationEnabled = value;
                });
              },),
          ),
          ListTile(
            title: Text('Language'),
            subtitle: Text('English'),
          ),
          ListTile(
            title: Text('Help'),
          ),
        ],
      ),
    );
  }
}

