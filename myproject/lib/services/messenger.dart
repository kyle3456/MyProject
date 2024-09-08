import 'package:http/http.dart' as http;
import 'package:image/image.dart' as imglib;
import 'dart:async';
import 'dart:io';

/*
def send_image_to_server(image_path, server_url):
    with open(image_path, 'rb') as image_file:
        files = {'file': image_file}
        response = requests.post(server_url, files=files)

    if response.status_code == 200:
        return response.json()
    else:
        return {"error": f"Server returned status code {response.status_code}"}

 */

String serverUrl = 'http://localhost:2500/predict';
var url = Uri.parse(serverUrl);

Future<String> sendImage(File image) async {
  imglib.Image? img = imglib.decodeImage(image.readAsBytesSync());

  // convert to jpg
  var jpg = imglib.encodeJpg(img!);

  var request = http.MultipartRequest('POST', url)
    ..files.add(http.MultipartFile.fromBytes('file', jpg, filename: 'image.jpg'));

  var response = await request.send();

  if (response.statusCode == 200) {
    return await response.stream.bytesToString();
  } else {
    return '{"error": "Server returned status code ${response.statusCode}"}';
  }
}
