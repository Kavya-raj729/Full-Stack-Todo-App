import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers//portfolio_providers.dart';

class DashboardScreen extends StatelessWidget {

  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final provider =
        Provider.of<PortfolioProvider>(context);

    final data = provider.portfolio;

    return Scaffold(

      appBar: AppBar(
        title: const Text("AI Dashboard"),
      ),

      body: data == null
          ? const Center(
              child: Text("No Data"),
            )

          : SingleChildScrollView(

              padding: const EdgeInsets.all(20),

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),

                      child: Column(

                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [

                          Text(
                            data.developerType,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            "Experience: ${data.experienceLevel}",
                          ),

                          const SizedBox(height: 10),

                          Text(
                            "ATS Score: ${data.atsScore}",
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "About Me",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(data.aboutMe),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Strengths",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Wrap(
                    spacing: 10,

                    children: data.strengths
                        .map(
                          (e) => Chip(
                            label: Text(e.toString()),
                          ),
                        )
                        .toList(),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Weaknesses",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Wrap(
                    spacing: 10,

                    children: data.weaknesses
                        .map(
                          (e) => Chip(
                            label: Text(e.toString()),
                          ),
                        )
                        .toList(),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Career Roles",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Wrap(
                    spacing: 10,

                    children: data.careerRoles
                        .map(
                          (e) => Chip(
                            label: Text(e.toString()),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
    );
  }
}