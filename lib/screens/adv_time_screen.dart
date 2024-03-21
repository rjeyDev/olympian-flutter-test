// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';

import '../services/ad_service.dart';
import '../styles.dart';

class AdvTimeScreen extends StatefulWidget {
  const AdvTimeScreen({super.key});

  @override
  State<AdvTimeScreen> createState() => _AdvTimeScreenState();
}

class _AdvTimeScreenState extends State<AdvTimeScreen> {
  late Timer _timer;


  @override
  void initState() {
    final AdService ad = AdService();
    _timer = Timer(const Duration(milliseconds: 1500), () async {
      ad.showFullScreenBanner();
      await Future.delayed(const Duration(milliseconds: 500));
      Navigator.pop(context);
      _timer.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(243, 206, 112, 1),
              Color.fromRGBO(217, 149, 86, 1),
            ],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 90,),
            const Expanded(
              flex: 1,
              child: Text(
                'Рекламная пауза',
                style: ThemeText.mainTitle,
              ),
            ),
            Expanded(
              flex: 10,
              child: Image.asset(
                'assets/images/tree.png',
                fit: BoxFit.fitHeight,
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }
}

