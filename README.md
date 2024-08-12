# SideQuests: Your Open-Source Appwrite Todo Companion

##  ⚔️ Conquer Your Daily Quests with SideQuests!

SideQuests is a beautifully crafted Flutter application designed to simplify your task management with the power of Appwrite. Leveraging the robust features of Appwrite's backend-as-a-service, this open-source project empowers you to build your own fully-functional todo list application.

## ✨ Features

- **Seamless Appwrite Integration:** Experience the ease of use and scalability of Appwrite for user authentication, data storage, and API management.
- **Intuitive Todo List:** Create, manage, and complete your side quests with a user-friendly interface.
- **Real-time Updates:** Witness your changes reflected instantly with Appwrite's real-time database capabilities.
- **Secure Authentication:** Rest assured with Appwrite's built-in authentication system, keeping your data safe and sound.
- **LaunchDarkly Feature Flags:** Experience the future of development with LaunchDarkly's powerful feature flag management, allowing for controlled rollouts and A/B testing. 

## 🚀 Getting Started

Follow these steps to get SideQuests up and running on your local machine:

1. **Clone the repository:**

   ```bash
   git clone https://github.com/jimbobbennett/sidequests.git
   ```

1. **Navigate to the project directory:**

   ```bash
   cd sidequests/mobile_app
   ```

1. **Install dependencies:**

   ```bash
   flutter pub get
   ```

1. Create the `.env` file

    - Copy the `.env.example` file to `.env`

1. **Set up Appwrite:**

    - Create an Appwrite account at [https://appwrite.io](https://appwrite.io).
    - Create a new Appwrite project.
    - Create an Appwrite database called `sidequests`
    - Create an Appwrite collection in your database called `sidequests`, with a string column called `name`, and a bool column called `completed`.
    - Configure your Appwrite project ID, database ID, and collection ID in the `.env` file.

1. **Set up LaunchDarkly (Optional):**

    - Create a LaunchDarkly account at [https://launchdarkly.com](https://launchdarkly.com).
    - Create a new LaunchDarkly project and obtain your mobile key.
    - Configure your LaunchDarkly mobile key in the `.env` file.

1. **Run the application:**

   ```bash
   flutter run
   ```

## 🛠️ Built With

- **Flutter:** A powerful and expressive framework for building beautiful native applications.
- **Appwrite:** A secure and scalable backend-as-a-service for web, mobile, and Flutter developers.
- **LaunchDarkly:** A feature management platform for safe and agile feature rollouts. 

## 🤝 Contributing

Contributions are welcome and encouraged!  To contribute to SideQuests:

1. **Fork the repository.**
2. **Create a new branch for your feature or bug fix.**
3. **Make your changes and commit them.**
4. **Push your changes to your forked repository.**
5. **Submit a pull request.**

##  📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details. 
