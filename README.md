# BrainBrawl 🧠⚔️
BrainBrawl is a social app built with SwiftUI where users engage in dynamic discussions by choosing sides in opinion-based debates. Pick your stance on hot topics, express your thoughts, and engage in meaningful conversations with others who share or oppose your view.

## Features 🌟  
Choose Your Stance: For every topic, pick a side that aligns with your opinion.  
Comment and Discuss: Share your thoughts, debate with others, and upvote or downvote comments.  
Topic Feed: Explore trending debates on various topics, from pop culture to politics.  
Profile and History: Keep track of the topics you’ve participated in and see where you stand.  
Push Notifications: Get notified when new topics are available or when others respond to your comments.  
Anonymous Mode: Join debates anonymously if you prefer to share your views without revealing your identity.


## Getting Started 🚀  
_Prerequisites_  
To run BrainBrawl on your local machine, make sure you have the following:  
Xcode 12 or later  
Swift 5.3 or later  
iOS 14 or later

## Installation  
Clone the repository:  
git clone https://github.com/yourusername/BrainBrawl.git  
Open the project in Xcode:  
cd BrainBrawl  
open BrainBrawl.xcodeproj

## Build and run the project:  
Select the iOS simulator or device from the toolbar in Xcode.  
Press Cmd + R to build and run the app.

__Usage__  
Once installed, create a profile mode to start participating in discussions. Choose your side in various debates, comment on the topic, and engage with other users' perspectives.

## Technologies Used 🛠️  
SwiftUI: For the app’s intuitive and interactive user interface.  
Combine: To handle asynchronous data flows and state management.  
Firebase: For real-time data storage, user authentication, and notifications.  
CoreData: Local storage to maintain discussion history and comments when offline.  
UIKit (Optional): For integrating components that SwiftUI may not yet fully support.

## Project Structure 📂  
/Models: Data models representing users, topics, comments, and more.  
/Views: SwiftUI views for the user interface, including topic screens, comment sections, and user profiles.  
/ViewModels: Handles the connection between data models and views, ensuring the app’s functionality and data flow.  
/Services: Manages data from Firebase and CoreData, including user authentication and storing debate topics.

## Contribution Guidelines 🤝  
Contributions are welcome! Here’s how you can help:  
Fork the repository.  
Create a feature branch (git checkout -b feature/YourFeatureName).  
Commit your changes (git commit -m 'Add some feature').  
Push to the branch (git push origin feature/YourFeatureName).  
Open a pull request, and provide a description of your work.  
Please ensure your changes are well-tested before submitting.

## Future Roadmap 🛣️  
Advanced Filtering: Add the ability to filter topics based on categories or personal interests.  
Live Polls: Integrate live polls to allow users to vote on their stance before participating in the debate.  
Moderation Tools: Implement reporting and moderation to ensure respectful discussions.  
Dark Mode: Provide a dark mode option for better usability in low-light environments.  
Profile Badges: Reward users for engaging in multiple discussions or providing high-quality contributions.

__License 📄__  
This project is licensed under the MIT License - see the LICENSE file for more details.
