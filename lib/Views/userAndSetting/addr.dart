import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location_permissions/location_permissions.dart' as prifix;
import 'package:location/location.dart';
import 'package:sirilike_flutter/model/network.dart';

class BoxAddrWidget extends StatefulWidget {
  @override
  _BoxAddrWidgetState createState() => _BoxAddrWidgetState();
}

class _BoxAddrWidgetState extends State<BoxAddrWidget> {
  TextEditingController controller = TextEditingController();
  Future future;
  String addrSearchStr = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          '地址选择',
          style: TextStyle(color: Colors.white),
        ),
        brightness: Brightness.dark,
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Row(
              children: <Widget>[
                Expanded(
                    child: TextField(
                  decoration: InputDecoration(
                      prefix: SizedBox(width: 15),
                      contentPadding: EdgeInsets.zero,
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 2, color: Colors.lightGreen)),
                      border: OutlineInputBorder()),
                      onChanged: (e){
                        addrSearchStr = e;
                      },
                )),
                SizedBox(width: 10),
                FlatButton(
                    onPressed: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                      future = nearListWithAddr(addrSearchStr);
                      setState(() {});
                    },
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    color: Colors.lightGreen,
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.search,
                          size: 18,
                          color: Colors.white,
                        ),
                        Text(
                          '搜索',
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    ))
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<NearbyPlace>>(
                future: future,
                builder: (context, snapshot) {
                  List<NearbyPlace> places = snapshot.data;
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (places == null) {
                      return Container(child: Center(child: Text('无法获取附近地点')));
                    }
                    if (places.length == 0){
                      return Container(child: Center(child: Text('没有找到附近的小区')));
                    }
                    return ListView.builder(
                      itemBuilder: (ctx, idx) {
                        NearbyPlace place = places[idx];
                        return FlatButton(
                          padding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          onPressed: () {
                            Navigator.of(context).pop(place.name);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Flexible(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        place.name,
                                        style: TextStyle(fontSize: 15),
                                      ),
                                      Text('${place.city}-${place.address}',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[500]))
                                    ]),
                              ),
                              FlatButton.icon(
                                  padding: const EdgeInsets.all(0),
                                  onPressed: null,
                                  icon: Icon(
                                    Icons.place,
                                    size: 16,
                                  ),
                                  label: Text(
                                      '${place.distance.toStringAsFixed(2)}Km'))
                            ],
                          ),
                        );
                      },
                      itemCount: places.length,
                    );
                  } else {
                    return Container(child: Center(child: Text('正在获取附近地点...')));
                  }
                }),
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    future = requestNearList();
    super.initState();
  }

  Future<LocationData> _getLocation() async {
    Location location = Location();
    try {
      LocationData data = await location.getLocation();
      return data;
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        print('没有权限');
      }
      return null;
    }
  }

  Future<List<NearbyPlace>> requestNearList() async {
    prifix.PermissionStatus permission =
        await prifix.LocationPermissions().requestPermissions();
    if (permission != prifix.PermissionStatus.granted) {
      return null;
    }
    LocationData curLocate = await _getLocation();
    if (curLocate == null) {
      return null;
    }
    print('lat: ${curLocate.latitude}  lng:${curLocate.longitude}');

    Response res = await NetManager.instance.dio
        .get('/api/location/nearby-blocks?lat=${curLocate.latitude}&lng=${curLocate.longitude}');
    if (res.data['err'] != 0) {
      return null;
    }

    return NearbyPlace.fromJsonList(res.data['data']['blocks']);
  }

  Future<List<NearbyPlace>> nearListWithAddr(String addr) async {
    Response res = await NetManager.instance.dio
        .get('/api/location/nearby-blocks?addr=$addr');
    if (res.data['err'] != 0) {
      return null;
    }

    return NearbyPlace.fromJsonList(res.data['data']['blocks']);
  }
}

class NearbyPlace {
  final String name;
  final double lat;
  final double lng;
  final String city;
  final String address;
  final double distance;

  NearbyPlace.fromJson(Map json)
      : name = json['name'],
        lat = json['lat'],
        lng = json['lng'],
        city = json['city'],
        address = json['address'],
        distance = json['distance'];

  static List<NearbyPlace> fromJsonList(List list) {
    return List<NearbyPlace>.generate(list.length, (idx) {
      return NearbyPlace.fromJson(list[idx]);
    });
  }
}
