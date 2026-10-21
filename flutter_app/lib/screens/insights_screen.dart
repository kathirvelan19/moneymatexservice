import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9FD),
      appBar: AppBar(
        title: const Text('AI Financial Insights', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF1D192B))),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1D192B)),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome, color: Color(0xFF5E43A5)),
            tooltip: 'Refresh Insights',
            onPressed: () => provider.fetchInsights(),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF5E43A5), Color(0xFF7B5EB8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF5E43A5).withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: Colors.amber, size: 36),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Powered by Gemini 3.6 Flash', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              SizedBox(height: 4),
                              Text('Automated intelligence & behavioral analysis based on your ledger.', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5E43A5),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.sync, color: Colors.white, size: 20),
                    label: const Text('Generate Smart Insights', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    onPressed: provider.isLoading ? null : () => provider.fetchInsights(),
                  ),
                  const SizedBox(height: 24),
                  if (provider.isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Column(
                          children: [
                            CircularProgressIndicator(color: Color(0xFF5E43A5)),
                            SizedBox(height: 12),
                            Text('Synthesizing spending behavior with Gemini AI...', style: TextStyle(color: Color(0xFF79747E), fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    )
                  else if (provider.insights.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFEFEBF6)),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.lightbulb_outline, size: 48, color: Color(0xFF5E43A5)),
                          SizedBox(height: 12),
                          Text('No insights generated yet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1D192B))),
                          SizedBox(height: 4),
                          Text('Tap "Generate Smart Insights" to receive AI recommendations based on your spending history.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF79747E), fontSize: 12)),
                        ],
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: provider.insights.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFEFEBF6)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3EEFF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.auto_awesome, color: Color(0xFF5E43A5), size: 18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  provider.insights[index],
                                  style: const TextStyle(fontSize: 13.5, color: Color(0xFF1D192B), height: 1.4, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
