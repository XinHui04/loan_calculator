import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as intl;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Car Loan',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Car Loan Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double _loanAmount = 0.0;
  double _netIncome = 0.0;
  double _interestRate = 0.0;
  int _loanPeriod = 1;
  bool _hasGuarantor = false;
  int _carType = 1; // 1 = new 2 = used
  double _repaymentAmount = 0.0;
  String _repaymentOutput = '';
  final _years = [1,2,3,4,5,6,7,8,9];

  //Controller
  final loanAmountCtrl = TextEditingController();
  final netIncomeCtrl = TextEditingController();
  final interestRateCtrl = TextEditingController();

  //set focus
  final _myFocusNode = FocusNode();

  //Format Output
  final myCurrency = intl.NumberFormat('#,##0.00','ms_MY');

  //Form Controller
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Loan Amount'
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  controller: loanAmountCtrl,
                  focusNode: _myFocusNode,
                  validator: (value){
                    if(value == null || value.isEmpty){
                      return 'Please enter loan amount';
                    }return null;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Net Income'
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  controller: netIncomeCtrl,
                  validator: (value){
                    if(value == null || value.isEmpty){
                      return 'Please enter net income';
                    }return null;
                  },
                ),
                DropdownButtonFormField(
                  value: _loanPeriod,
                  items: _years.map((int item){
                    return DropdownMenuItem(
                      value: item,
                      child: Text('$item year(s)' )
                    );
                }).toList(),
                  onChanged: (int? item){
                    setState(() {
                      _loanPeriod = item!;
                    });
                  }, decoration: const InputDecoration(
                    labelText: 'Select Loan period (year)'
                ),
                  validator: (value){
                    if(value == 0){
                      return 'Please select an option';
                    }return null;
                  },
                ),
                TextFormField(
                  controller: interestRateCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: false,
                  ),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0 - 9]'))],
                  decoration: const InputDecoration(
                    labelText: 'Interest rate (%)'
                  ),
                  validator: (value){
                    if(value == null || value.isEmpty){
                      return 'Please enter interest rate';
                    }return null;
                  },
                ),
                CheckboxListTile(
                    value: _hasGuarantor,
                    title: const Text('I have guarantor.'),
                    onChanged: (value){
                      setState(() {
                        _hasGuarantor = value!;
                      });
                    }),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Car Type',
                    textDirection: TextDirection.ltr,),
                ),
                RadioListTile(
                    value: 1,
                    title: const Text('New'),
                    groupValue: _carType,
                    onChanged: (value){
                      setState(() {
                        _carType = value!;
                      });
                    }),
                RadioListTile(
                    value: 2,
                    title: const Text('Used'),
                    groupValue: _carType,
                    onChanged: (value){
                      setState(() {
                        _carType = value!;
                      });
                    }),
                Text(_repaymentOutput),
                ElevatedButton(
                    onPressed: (){
                      if(_formKey.currentState!.validate(){
                        if(validInterest(_carType)){
                          _calculateRepayment();
                        }else{
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content:Text('Invalid Interest rate'))
                          );
                      }
                      }},child: Text('Calcuulator'))

              ],
            ),
          ),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
  void myAlertDialog(){
    AlertDialog eligibilityAlertDialog = AlertDialog(
      title: const Text('Eligibility'),
      content: const Text('You are not eligible for this loan. '
          'Get a guarantor to proceed'),
      actions: [
        TextButton(
            onPressed: (){
              Navigator.pop(context);
            },
            child: Text('OK'))
      ],
    );
    showDialog(context: context, builder: (BuildContext context){
      return eligibilityAlertDialog;
    });
  }
  void _calculateRepayment(){
    _loanAmount = double.tryParse(loanAmountCtrl.text)!;
    _netIncome = double.tryParse(netIncomeCtrl.text)!;
    _interestRate = double.tryParse(interestRateCtrl.text)!;

    var interest = _loanAmount * (_interestRate/100) * _loanPeriod;
    _repaymentAmount = (_loanAmount + interest) / (_loanPeriod * 12);

    bool eligible = _netIncome * 0.3 >= _repaymentAmount;
    if (eligible || _hasGuarantor){
      setState(() {
        _repaymentOutput = 'Repayment Amount : '
            '${myCurrency.currencySymbol}'
            '${myCurrency.format(_repaymentAmount)}'
            '\n'
            'Eligibility : ${eligible? 'Eligible': 'Not Eligible'}';
      });
    }
  }
}

