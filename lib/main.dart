import 'package:flutter/material.dart';

import 'demo_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePageDemo(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final DateTime _currentTime = DateTime.now();
  late int _hour;
  late int _min;
  late String _time;
  final String _am = 'AM';
  final String _pm = 'PM';

  @override
  void initState() {
    super.initState();
    _hour = _currentTime.hour;
    _min = _currentTime.minute;
    _time = _am;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const Text(
            '1:35 PM',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          Row(
            children: [
              item(onNext: _onHourNext, onPre: onHourPre, value: '$_hour'),
              const SizedBox(width: 20,),
              item(onNext: _onMinNext, onPre: onMinPre, value: '$_min'),
              const SizedBox(width: 20,),
              item(onNext: _onChangeTime, onPre: _onChangeTime, value: _time),
            ],
          )
        ],
      ),
    );
  }

  Widget item({
    required String value,
    required VoidCallback onNext,
    required VoidCallback onPre,
  }) {
    return Column(
      children: [
        IconButton(
          onPressed: onNext,
          icon: const Icon(
            Icons.arrow_drop_up,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 30
          ),
        ),
        IconButton(
          onPressed: onPre,
          icon: const Icon(
            Icons.arrow_drop_down,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  void _onHourNext() {
    if (_hour >= 12) {
      setState(() {
        _hour = 1;
      });
    } else {
      if (_hour == 11) {
        // _time = _pm;
        _onChangeTime();
      }
      setState(() {
        _hour += 1;
      });
    }
  }

  void onHourPre() {
    if (_hour <= 1) {
      setState(() {
        _hour = 12;
      });
    } else {
      setState(() {
        _hour = _hour - 1;
      });
      if (_hour == 11) {
        // _time = _am;
        _onChangeTime();
      }
    }
  }

  void _onMinNext() {
    if (_min >= 59) {
      setState(() {
        _min = 0;
      });
    } else {
      setState(() {
        _min += 1;
      });
    }
  }

  void onMinPre() {
    if (_min <= 1) {
      setState(() {
        _min = 59;
      });
    } else {
      setState(() {
        _min -= 1;
      });
    }
  }

  void _onChangeTime() {
    if (_time == _am) {
      setState(() {
        _time = _pm;
      });
    } else {
      setState(() {
        _time = _am;
      });
    }
  }
}
