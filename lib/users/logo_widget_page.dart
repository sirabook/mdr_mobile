import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LogoWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'MDR',
            style: GoogleFonts.marcellusSc(
              fontSize: 100,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 2,
              shadows: [
                Shadow(
                  blurRadius: 10,
                  color: Colors.black54,
                  offset: Offset(2, 2),
                ),
              ],
            ),
          ),
          Text(
            'CENTER',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
