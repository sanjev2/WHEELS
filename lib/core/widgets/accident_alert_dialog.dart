// import 'dart:async';
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';

// class AccidentAlertDialog extends StatefulWidget {
//   final String sosNumber;

//   const AccidentAlertDialog({super.key, required this.sosNumber});

//   @override
//   State<AccidentAlertDialog> createState() => _AccidentAlertDialogState();
// }

// class _AccidentAlertDialogState extends State<AccidentAlertDialog>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _pulseController;
//   late final Animation<double> _outerScale;
//   late final Animation<double> _innerScale;
//   late final Animation<double> _fadeAnimation;

//   Timer? _countdownTimer;
//   int _secondsLeft = 10;
//   bool _actionTaken = false;

//   @override
//   void initState() {
//     super.initState();

//     _pulseController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1400),
//     )..repeat();

//     _outerScale = Tween<double>(
//       begin: 1.0,
//       end: 1.35,
//     ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeOut));

//     _innerScale = Tween<double>(begin: 1.0, end: 1.08).animate(
//       CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
//     );

//     _fadeAnimation = Tween<double>(
//       begin: 0.35,
//       end: 0.0,
//     ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeOut));

//     _startCountdown();
//   }

//   void _startCountdown() {
//     _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
//       if (!mounted || _actionTaken) {
//         timer.cancel();
//         return;
//       }

//       if (_secondsLeft <= 1) {
//         timer.cancel();
//         _actionTaken = true;
//         if (mounted) {
//           Navigator.of(context).pop(true);
//         }
//       } else {
//         setState(() {
//           _secondsLeft--;
//         });
//       }
//     });
//   }

//   void _cancelAlert() {
//     if (_actionTaken) return;
//     _actionTaken = true;
//     _countdownTimer?.cancel();
//     Navigator.of(context).pop(false);
//   }

//   void _callNow() {
//     if (_actionTaken) return;
//     _actionTaken = true;
//     _countdownTimer?.cancel();
//     Navigator.of(context).pop(true);
//   }

//   @override
//   void dispose() {
//     _countdownTimer?.cancel();
//     _pulseController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 340,
//       margin: const EdgeInsets.symmetric(horizontal: 24),
//       padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(28),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.14),
//             blurRadius: 30,
//             offset: const Offset(0, 14),
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           AnimatedBuilder(
//             animation: _pulseController,
//             builder: (context, child) {
//               return SizedBox(
//                 width: 120,
//                 height: 120,
//                 child: Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     FadeTransition(
//                       opacity: _fadeAnimation,
//                       child: ScaleTransition(
//                         scale: _outerScale,
//                         child: Container(
//                           width: 88,
//                           height: 88,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             color: Colors.red.withOpacity(0.18),
//                           ),
//                         ),
//                       ),
//                     ),
//                     ScaleTransition(
//                       scale: _innerScale,
//                       child: Container(
//                         width: 84,
//                         height: 84,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: Colors.red.shade600,
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.red.withOpacity(0.35),
//                               blurRadius: 20,
//                               offset: const Offset(0, 8),
//                             ),
//                           ],
//                         ),
//                         child: const Center(
//                           child: Text(
//                             'SOS',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 24,
//                               fontWeight: FontWeight.w800,
//                               letterSpacing: 1.2,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//           const SizedBox(height: 18),
//           const Text(
//             'Possible accident detected',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: 22,
//               fontWeight: FontWeight.w700,
//               color: Color(0xFF111827),
//             ),
//           ),
//           const SizedBox(height: 10),
//           const Text(
//             'A strong impact was detected. If you do not cancel, SOS will be opened automatically.',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: 15,
//               height: 1.5,
//               color: Color(0xFF6B7280),
//             ),
//           ),
//           const SizedBox(height: 18),
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
//             decoration: BoxDecoration(
//               color: const Color(0xFFF9FAFB),
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(color: const Color(0xFFE5E7EB)),
//             ),
//             child: Column(
//               children: [
//                 const Text(
//                   'Calling SOS in',
//                   style: TextStyle(
//                     fontSize: 13,
//                     color: Color(0xFF6B7280),
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   '$_secondsLeft s',
//                   style: TextStyle(
//                     fontSize: 28,
//                     fontWeight: FontWeight.w800,
//                     color: Colors.red,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 24),
//           Row(
//             children: [
//               Expanded(
//                 child: SizedBox(
//                   height: 52,
//                   child: OutlinedButton(
//                     onPressed: _cancelAlert,
//                     style: OutlinedButton.styleFrom(
//                       side: const BorderSide(color: Color(0xFFD1D5DB)),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(14),
//                       ),
//                     ),
//                     child: const Text(
//                       'Cancel',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                         color: Color(0xFF111827),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 14),
//               Expanded(
//                 child: SizedBox(
//                   height: 52,
//                   child: ElevatedButton(
//                     onPressed: _callNow,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.red.shade600,
//                       foregroundColor: Colors.white,
//                       elevation: 0,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(14),
//                       ),
//                     ),
//                     child: const Text(
//                       'Call SOS',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// Future<void> openSosDialer(String sosNumber) async {
//   if (!Platform.isAndroid) return;

//   final Uri telUri = Uri(scheme: 'tel', path: sosNumber);

//   final bool launched = await launchUrl(
//     telUri,
//     mode: LaunchMode.externalApplication,
//   );

//   if (!launched) {
//     throw Exception('Could not open SOS dialer');
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';

class AccidentAlertDialog extends StatefulWidget {
  const AccidentAlertDialog({super.key, this.initialSeconds = 10});

  final int initialSeconds;

  @override
  State<AccidentAlertDialog> createState() => _AccidentAlertDialogState();
}

class _AccidentAlertDialogState extends State<AccidentAlertDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _outerScale;
  late final Animation<double> _innerScale;
  late final Animation<double> _fadeAnimation;

  Timer? _countdownTimer;
  late int _secondsLeft;
  bool _actionTaken = false;

  @override
  void initState() {
    super.initState();

    _secondsLeft = widget.initialSeconds;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _outerScale = Tween<double>(
      begin: 1.0,
      end: 1.35,
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeOut));

    _innerScale = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.35,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeOut));

    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _actionTaken) {
        timer.cancel();
        return;
      }

      if (_secondsLeft <= 1) {
        _actionTaken = true;
        timer.cancel();
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _secondsLeft--;
        });
      }
    });
  }

  void _cancelAlert() {
    if (_actionTaken) return;
    _actionTaken = true;
    _countdownTimer?.cancel();
    Navigator.of(context).pop(false);
  }

  void _callNow() {
    if (_actionTaken) return;
    _actionTaken = true;
    _countdownTimer?.cancel();
    Navigator.of(context).pop(true);
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 340,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.14),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _outerScale,
                        child: Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red.withOpacity(0.18),
                          ),
                        ),
                      ),
                    ),
                    ScaleTransition(
                      scale: _innerScale,
                      child: Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red.shade600,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.35),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'SOS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 18),
          const Text(
            'Possible accident detected',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'A strong impact was detected. If you do not cancel, SOS will be called automatically.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                const Text(
                  'Calling SOS in',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_secondsLeft s',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton(
                    onPressed: _cancelAlert,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFD1D5DB)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _callNow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Call SOS',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
