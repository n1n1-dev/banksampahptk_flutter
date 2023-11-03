import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../constant/constant.dart';
import '../models/data_services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DataServices service = DataServices();
  int banksampahCount = 0;
  int jenissampahCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchDataCount();
  }

  Future<void> _fetchDataCount() async {
    int countBS = await service.banksampahSum();
    int countJBS = await service.jenissampahSum();
    setState(() {
      banksampahCount = countBS;
      jenissampahCount = countJBS;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        slivers: <Widget>[
          const SliverAppBar(
            expandedHeight: 150.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Beranda'),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      color: Colors.greenAccent,
                    ),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 40),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Bank Sampah",
                                style: CustomBS.titleListSampah,
                              ),
                              Text(
                                "$banksampahCount",
                                style: CustomBS.titleHargaSampah,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 40),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Jenis Sampah",
                                style: CustomBS.titleListSampah,
                              ),
                              Text(
                                "$jenissampahCount",
                                style: CustomBS.titleHargaSampah,
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              childCount: 1,
            ),
          ),
          SliverFillRemaining(
            child: Center(
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 50,
                  borderData: FlBorderData(show: false),
                  sections: getSections(),
                ),
                swapAnimationDuration:
                    const Duration(milliseconds: 150), // Optional
                swapAnimationCurve: Curves.linear, //
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> getSections() {
    return [
      PieChartSectionData(
        title: "Bank Sampah",
        value: jenissampahCount.toDouble(),
        color: Colors.green,
        showTitle: true,
        radius: 40,
        titleStyle: CustomBS.titleForm,
      ),
      PieChartSectionData(
        title: 'Jenis Sampah',
        value: banksampahCount.toDouble(),
        color: Colors.orange,
        showTitle: true,
        radius: 45,
        titleStyle: CustomBS.titleForm,
      ),
    ];
  }
}
