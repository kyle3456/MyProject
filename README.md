# MyProject


How the watch works with app
1. Admin makes student account
2. Admin/Teacher account can then pair/unpair device to an account
    - Pairing is bacially just sending the device the email and password of the student account as well as the wifi info.

How does the device work?

    Firebase Student Account Structure:
    {
        admin: [admin_uid],
        location: [location],
        status: "normal",
        type: "student",
    }

1. The device needs the following abilities:
    - wi-fi
    - haptic motor
2. Upon boot, it connects to wi-fi and then logs in to Firebase with the given student account.
3. It then periodically updates its current location and writes it to the student account.
4. The teacher will click on a student card and then they will write to the student's status. 
5. The student will get a buzz telling them of danger.
