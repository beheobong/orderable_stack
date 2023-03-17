import 'package:flutter/material.dart';

import 'orderable_stack/orderable_stack.dart';

class MyHomePageDemo extends StatefulWidget {
  const MyHomePageDemo({Key? key}) : super(key: key);


  @override
  _MyHomePageDemoState createState() => _MyHomePageDemoState();
}

const kItemSize =  Size.square(80.0);
const kChars =  ["A", "B", "C", "D"];

class _MyHomePageDemoState extends State<MyHomePageDemo> {
  List<String> chars = ["A", "B", "C", "D"];
  List<Img> imgs = const [
    Img("assets/girafe1.png", "Gi"),
    Img("assets/girafe2.png", "ra"),
    Img("assets/girafe3.png", "ffe"),
  ];

  bool imgMode = false;

  ValueNotifier<String> orderNotifier = ValueNotifier<String>('');

  @override
  Widget build(BuildContext context) {
    OrderPreview preview = OrderPreview(orderNotifier: orderNotifier);
    Size gSize = MediaQuery.of(context).size;
    return Scaffold(
        body:
            Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('Text'),
            Switch(
                value: imgMode,
                onChanged: (value) => setState(() => imgMode = value)),
            const Text('Image'),
          ]),
          preview,
          Center(
              child: imgMode
                  ? OrderableStack<Img>(
                      items: imgs,
                      itemSize: gSize.width < gSize.height
                          ? Size(gSize.width / 3, gSize.height - 200.0)
                          : Size(200.0, gSize.height - 300.0),
                      margin: 0.0,
                      itemBuilder: imgItemBuilder,
                      onChange: (List<Object> orderedList) =>
                          orderNotifier.value = orderedList.toString())
                  : OrderableStack<String>(
                      direction: Direction.vertical,
                      items: chars,
                      itemSize: const Size(200.0, 50.0),
                      itemBuilder: itemBuilder,
                      onChange: (List<String> orderedList) =>
                          orderNotifier.value = orderedList.toString()))
        ]));
  }

  Widget itemBuilder({Orderable<String>? data, Size? itemSize}) {
    return Container(
      key: Key("orderableDataWidget${data!.dataIndex}"),
      color: !data.selected
          ? data.dataIndex == data.visibleIndex ? Colors.lime : Colors.cyan
          : Colors.orange,
      width: itemSize!.width,
      height: itemSize.height,
      child: Center(
          child: Column(children: [
        Text(
          data.value,
          style: const TextStyle(fontSize: 36.0, color: Colors.white),
        )
      ])),
    );
  }

  Widget imgItemBuilder({Orderable<Img>? data, Size? itemSize}) => Container(
        color: data != null && !data.selected
            ? data.dataIndex == data.visibleIndex ? Colors.lime : Colors.cyan
            : Colors.orange,
        width: itemSize!.width,
        height: itemSize.height,
        child: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
              Image.asset(
                data!.value.url,
                fit: BoxFit.contain,
              ),
            ])),
      );
}

class Img {
  final String url;
  final String title;
  const Img(this.url, this.title);

  @override
  String toString() => 'Img{title: $title}';
}

class OrderPreview extends StatefulWidget {
  final ValueNotifier orderNotifier;

  const OrderPreview({super.key, required this.orderNotifier});

  @override
  State<StatefulWidget> createState() => OrderPreviewState();
}

class OrderPreviewState extends State<OrderPreview> {
  String data = '';

  OrderPreviewState();

  @override
  void initState() {
    super.initState();
    widget.orderNotifier
        .addListener(() => setState(() => data = widget.orderNotifier.value));
  }

  @override
  Widget build(BuildContext context) => Text(data);
}