import requests

def send_image_to_server(image_path, server_url):
    with open(image_path, 'rb') as image_file:
        files = {'file': image_file}
        response = requests.post(server_url, files=files)

    if response.status_code == 200:
        return response.json()
    else:
        return {"error": f"Server returned status code {response.status_code}"}

def main():
    # Replace with the path to your image and the URL of your Flask server
    image_path = 'example.jpg'
    server_url = 'http://localhost:2500/predict'

    # Send the image to the server and get the response
    result = send_image_to_server(image_path, server_url)

    if "error" in result:
        print(f"Error: {result['error']}")
    else:
        print("Predictions:")
        for prediction in result["predictions"]:
            print(f"Class: {prediction['class']}, Confidence: {prediction['confidence']}")

if __name__ == '__main__':
    main()