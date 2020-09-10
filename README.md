# Employ - A Social Networking App for IOS 

I built my own social networking platform from scratch for a job employment application on IOS which included features such as: a friend request system, an intelligent search engine, a unique job management system, a user location tracking system with the integration of a Google API, a Distance Matrix API was integrated to calculate distances and durations between users. A cloud hosted JSON tree was used to store, retrieve and manage data. This project was accomplished using: a large number of self-taught skills, development of my own algorithms and extensive research.

The app consists of 6 main pages: log in, profile, search, jobs, contacts and info.
Below are some screenshots which show what the first 4 pages look like.

![alt text](https://github.com/HarrishanSK/SocialNetworkingAppForIOS/blob/master/images/image1.png)

When a user logs in through the log in page the entered credentials are sent to the server and confirmed based on the information stored in the cloud hosted JSON tree. If the log in is successful, the user's 'profile page' would be loaded along with the navigation bar at the bottom of the screen. From this point onwards the user can navigate through the remaining 4 pages.

![alt text](https://github.com/HarrishanSK/SocialNetworkingAppForIOS/blob/master/images/image2.png)

The above 2 pages show the contacts and info pages. The contact page stores a list of users who you have connected with using the app (similar to a friend list on facebook). The info page provides helpful information to navigate around the app.

![alt text](https://github.com/HarrishanSK/SocialNetworkingAppForIOS/blob/master/images/image4.png)
When the user clicks on a contact the above transition takes place. The user will be able to: view information about the contact, call or message and even see how far away the contact is from the users location. Furtheremore, the duration for the user to meet the contact will be shown with different methods of transportation (e.g: car, cycle, public transport or by walking).

![alt text](https://github.com/HarrishanSK/SocialNetworkingAppForIOS/blob/master/images/image3.png)
The above image shows some examples when using the search engine. A user (employer) can type a problem or keyword into the search engine, the algorithm will then use keyword analysis techniques to recocomend a list of freelance workers (employees) (nearby based on who is closest) to fix the 'problem'.


More info:
See './EmployPresentation.pdf' for an overview of the software that was developed and for screenshots & UML diagrams of the final product.
Code can be found in the './employ' and must be run on a a mac running Mac OS 10.13.2 or later.
Open the project on Xcode11 running swift4.
