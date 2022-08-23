import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PaywallWidget extends StatefulWidget {
  final String title;
  final String description;
  final List<Package> packages;
  final ValueChanged<Package> onClickedPackage;

  const PaywallWidget({
    Key? key,
    required this.title,
    required this.description,
    required this.packages,
    required this.onClickedPackage,
  }) : super(key: key);

  @override
  _PaywallWidgetState createState() => _PaywallWidgetState();
}

class _PaywallWidgetState extends State<PaywallWidget> {
  @override
  Widget build(BuildContext context) => Container(
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.75,
    ),
    child: SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: <Widget>[
          Text(
            widget.title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            widget.description,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 16),
          buildPackages(),
        ],
      ),
    ),
  );

  Widget buildPackages() => ListView.builder(
    shrinkWrap: true,
    primary: false,
    itemCount: widget.packages.length,
    itemBuilder: (context, index) {
      final package = widget.packages[index];

      return buildPackage(context, package);
    },
  );

  Widget buildPackage(BuildContext context, Package package) {
    final product = package.storeProduct;

    return Card(
      color: Theme.of(context).accentColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: ThemeData.light(),
        child: ListTile(
          contentPadding: EdgeInsets.all(8),
          title: Text(
            product.title,
            style: TextStyle(fontSize: 18),
          ),
          subtitle: Text(product.description),
          trailing: Text(
            product.priceString,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          onTap: () => widget.onClickedPackage(package),
        ),
      ),
    );
  }
}