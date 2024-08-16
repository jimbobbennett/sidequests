# SideQuests: Your Open-Source Todo Companion

This repo contains an example ToDo app using Flutter, with ToDo items considered as side quests. What makes this app different to other reference ToDo app implementations is that it is configurable via feature flag to be either all local, or running in the cloud. This repo is designed to show 3 concepts:

- How you can leverage [Pieces for Developers](https://pieces.app) to help you develop an app
- How to use [Launch Darkly](https://launchdarkly.com) to control the features of your app, allowing you to test out a feature for some users before a full roll-out.
- How to use [Appwrite](https://appwrite.io) to provide a back end for a Flutter app.

> Remember to install [Pieces](https://pieces.app) and the [browser extension for your current browser](https://pieces.app/plugins/web-extension) when reading this code, as that way you can quickly save code snippets to Pieces using the **Copy and save button** that appears when you hover over any code.

Launch Darkly is used to quickly flip between offline only, and Appwrite for the storage of the side quests, allowing you to run this app fully offline for a trial rollout, then flip to the cloud to support synching of side quests.

## Configure the cloud services

You will need to manually configure the relevant cloud services, then store the appropriate API keys in the [`.env`](./mobile-app/.env) file. This repo doesn't ship with a `.env` file, and this file is ignored in the `.gitignore` to avoid accidentally committing your keys to source code control. There is an `.env.example` file that shows you the keys you need to set.

1. Copy `.env.example` to `.env`
1. Set up the services listed below and set the relevant keys in the `.env` file.

### Launch Darkly

1. Create a LaunchDarkly account at [https://launchdarkly.com](https://launchdarkly.com) if you don't have one.
1. Create a new LaunchDarkly project and obtain your mobile key.
1. Configure your LaunchDarkly mobile key in the `.env` file.

   ```ini
   LAUNCHDARKLY_MOBILE_KEY=mob-xxx
   ```

1. Add a [new custom boolean flag](https://docs.launchdarkly.com/home/flags/custom) with the key `use-appwrite`, and tick the **SDKs using Mobile Key** checkbox

   ![The new custom Use appwrite boolean flag](./img/use-appwrite-flag.webp)
   ![The use SDKs using mobile key setting](./img/flag-use-mobile-key.webp)


### Appwrite

1. Create an Appwrite account at [https://appwrite.io](https://appwrite.io).
1. Create a new Appwrite project.
1. Create an Appwrite database called `sidequests`
1. Create an Appwrite collection in your database called `sidequests`, with a string column called `name`, and a bool column called `completed`.
1. Configure your Appwrite project ID, database ID, and collection ID in the `.env` file.

   ```ini
   APPWRITE_PROJECT_ID=xxx
   APPWRITE_DATABASE_ID=sidequests
   APPWRITE_COLLECTION_ID=xxx
   ```

## Build and run the app

This is a Flutter app, so you will need to have Flutter installed by following the [Flutter install documentation](https://docs.flutter.dev/get-started/install).

1. Navigate to the project directory:

   ```bash
   cd sidequests/mobile_app
   ```

1. Install dependencies:

   ```bash
   flutter pub get
   ```

1.Run the application:

   ```bash
   flutter run
   ```

## Use the feature flag

To control the feature flag, you can turn it on and off from the Launch Darkly project. By default with a boolean flag, when it is turned off, evaluations will return `false`, and when turned on, evaluations will return `true`. There are more controls for this, including targeting certain users, and you can read about this in the [Launch Darkly flags documentation](https://docs.launchdarkly.com/home/flags/toggle).

When you first create the flag, it will be off and evaluate to `false`. This means when you run SideQuests, you will not need to log in, and all your sidequests will be stored locally in a SQLite database.

To flip to using Appwrite, turn this flag on, select **Review and Save**, enter the environment name to confirm - this should be `production`, then select **Save**.

![Turning the flag on and confirming the environment](./img/turn-flag-on.gif)

The app will then reload and you will then need to create an account and log in. Once done, you can save side quests to Appwrite.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details. 
