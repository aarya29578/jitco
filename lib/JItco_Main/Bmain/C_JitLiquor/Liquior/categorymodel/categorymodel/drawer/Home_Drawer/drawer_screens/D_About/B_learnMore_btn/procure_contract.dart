import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:velocity_x/velocity_x.dart';

class ProcureContract extends StatelessWidget {
  final List<String> title;
  final List<String> subtitle;
  const ProcureContract({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    RxInt number = 0.obs;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              10.heightBox,
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: title.length,
                itemBuilder: (context, index) {
                  RxInt num = number++;
                  return ListTile(
                    leading: Text(
                      num.toString(),
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.orange.shade700,
                      ),
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title[index],
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(subtitle[index], style: TextStyle(fontSize: 13)),
                      ],
                    ),
                    // subtitle: Text(
                    //   'jhvcvchbhjaklbvdclhjabdjc baskjvbhksbdvhjbasdvhj bchd',
                    // ),
                  );
                },
              ),
              18.heightBox,
            ],
          ),
        ),
      ),
    );
  }
}
