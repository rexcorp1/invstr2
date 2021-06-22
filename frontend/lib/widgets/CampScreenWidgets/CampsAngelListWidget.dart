import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;

class CampsAngelListWidget extends StatelessWidget {
  final Map selectedCamp;

  CampsAngelListWidget(this.selectedCamp);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder<dynamic>(
        future: getCampsAngels(
          selectedCamp['campAddress'],
        ),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Padding(
              padding: const EdgeInsets.only(top: 50.0),
              child: Column(
                children: [
                  SpinKitThreeBounce(
                    color: Theme.of(context).primaryColor,
                    size: 25.0,
                  ),
                ],
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.none) {
            return Padding(
              padding: const EdgeInsets.only(top: 50.0),
              child: Column(
                children: [
                  SpinKitThreeBounce(
                    color: Theme.of(context).primaryColor,
                    size: 25.0,
                  ),
                ],
              ),
            );
          }
          if (snapshot.data['result'] == false) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 60.0,
                  right: 60.0,
                  top: 310,
                ),
                child: Text(
                  'There was a problem fetching camp details, please try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data['list'].length,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.only(
                  top: 5,
                  bottom: 10,
                ),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: Color.fromRGBO(245, 245, 245, 1),
                ),
                width: MediaQuery.of(context).size.width - 40,
                height: 53,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Text(
                        snapshot.data['list'][index]['username'],
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        getAngelsFunding(selectedCamp['campAddress'],
                                snapshot.data['list'][index]['eth_address'])
                            .then(
                          (data) {
                            if (data['result'] == true) {
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  elevation: 20.0,
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  padding: EdgeInsets.all(35),
                                  content: Text(
                                    snapshot.data['list'][index]['username'] +
                                        '\'s investment : ' +
                                        data['details'] +
                                        ' CTV',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 17, color: Colors.white),
                                  ),
                                ),
                              );
                            } else if (data['result'] == false) {
                              print(data);
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.red,
                                  padding: EdgeInsets.all(20),
                                  content: Text(
                                    "Please try again later",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 17,
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text('Check investment'),
                      ),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        primary: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            25,
                          ),
                        ),
                        minimumSize: Size(100, 70),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// Get all the investors of a camp

Future<dynamic> getCampsAngels(String campAddress) async {
  var headers = {'Content-Type': 'application/json'};
  var request = http.Request(
      'POST', Uri.parse('http://3.15.217.59:8080/api/getCampsAngelInvestors'));
  request.body = json.encode({"camp_address": campAddress});
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  return await jsonDecode(await response.stream.bytesToString());
}

// Get investment done by a particular angel

Future<dynamic> getAngelsFunding(
    String campAddress, String angelAddress) async {
  var headers = {'Content-Type': 'application/json'};
  var request = http.Request(
      'POST', Uri.parse('http://3.15.217.59:8080/api/getFundingDetails'));
  request.body =
      json.encode({"camp_address": campAddress, "angel_address": angelAddress});
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  return await jsonDecode(await response.stream.bytesToString());
}