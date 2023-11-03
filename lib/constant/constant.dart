import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

const kPrimaryColor = Color(0xffF9EAFF);

const lPrimaryColor = Color(0xff4E31BC);
const mPrimaryColor = Color(0xff7752E2);
const nPrimaryColor = Color(0xff9F74FF);

const oPrimaryColor = Color(0xffB789FF);
const pPrimaryColor = Color(0xffEFBDFF);

const tlPrimaryColor = Color(0xff0B666A);

const dlPrimaryColor = Color(0xff9E9FA5);
const orangeColorBS = Color(0xffFF8B13);
const yellowColorBS = Color(0xffF0EB8D);
const pinkColorBS = Color(0xffEB455F);

class CustomBS {
  static TextStyle titleDark = GoogleFonts.raleway(
      textStyle: const TextStyle(color: Colors.black, fontSize: 14.0));

  static TextStyle titlePurple = GoogleFonts.raleway(
      textStyle: const TextStyle(color: lPrimaryColor, fontSize: 14.0));

  static TextStyle titleBar = GoogleFonts.rubik(
      textStyle: const TextStyle(color: Colors.white, fontSize: 18.0));

  static TextStyle titleListSampah = GoogleFonts.lora(
      textStyle: const TextStyle(color: Colors.black, fontSize: 16.0));

  static TextStyle subtitleListSampah = GoogleFonts.raleway(
      textStyle:
          TextStyle(color: Colors.black.withOpacity(0.6), fontSize: 14.0));

  static TextStyle titleHargaSampah = GoogleFonts.kanit(
      textStyle: const TextStyle(color: Colors.black, fontSize: 18.0));

  static TextStyle titleForm = GoogleFonts.lora(
      textStyle: const TextStyle(
          color: Colors.black, fontSize: 14.0, fontWeight: FontWeight.bold));

  static TextStyle inputtitleForm = GoogleFonts.lora(
      textStyle: const TextStyle(color: Colors.black, fontSize: 16.0));

  static TextStyle titleButton = GoogleFonts.abel(
      textStyle: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold));

  static InputDecoration decorationForm = InputDecoration(
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2)));

  static ButtonStyle buttonPurple = ElevatedButton.styleFrom(
    elevation: 5,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.0),
        side: const BorderSide(color: Colors.deepPurple, width: 1)),
    foregroundColor: Colors.deepPurple,
    backgroundColor: kPrimaryColor,
  );

  static ButtonStyle buttonOrange = ElevatedButton.styleFrom(
    elevation: 5,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: yellowColorBS.withOpacity(0.6), width: 1)),
    foregroundColor: Colors.white,
    backgroundColor: orangeColorBS.withOpacity(0.8),
  );

  static ButtonStyle buttonPink = ElevatedButton.styleFrom(
    elevation: 5,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: yellowColorBS.withOpacity(0.6), width: 1)),
    foregroundColor: Colors.white,
    backgroundColor: pinkColorBS.withOpacity(0.8),
  );

  static ButtonStyle buttonBack = ElevatedButton.styleFrom(
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: Colors.white.withOpacity(0.2), width: 1)),
    foregroundColor: kPrimaryColor,
    backgroundColor: Colors.transparent,
  );

  static ButtonStyle buttonWhiteOrange = ElevatedButton.styleFrom(
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
        side: BorderSide(color: Colors.white.withOpacity(0.2), width: 1)),
    foregroundColor: orangeColorBS,
    backgroundColor: Colors.white,
  );
}

class CurrencyFormat {
  static String convertToIdr(dynamic number, int decimalDigit) {
    NumberFormat currencyFormatter = NumberFormat.currency(
        locale: 'id', symbol: 'Rp ', decimalDigits: decimalDigit);
    return currencyFormatter.format(number);
  }
}
