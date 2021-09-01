import React from 'react';
import { NativeModules, Button } from 'react-native';

const { ClangNotificationModule } = NativeModules;

const data = {
    notificationId: "notificationId",
    notificationCategory: "notificationCategory",
    type: "clang",
    notificationTitle: "notificationTitle",
    notificationBody: "notificationBody",
    action1Id: "action1Id",
    action1Title : "action1Title",
    action2Id : "action2Id",
    action2Title : "action2Title",
};

const eventData = {
    email: "test@gmail.com",
}

const NewTestButton = () => {
    const onPress = async () => {
        try {
            // const notification = await ClangNotificationModule.createNotification(data);
            // console.log(notification);

            // const notification = await ClangNotificationModule.isClangNotification(data);
            // console.log(notification);

            // await ClangNotificationModule.updateProperties(data);
            // console.log("success");

            // await ClangNotificationModule.updateTokenOnServer("token");
            // console.log("success");

            // const id = await ClangNotificationModule.registerAccount();
            // console.log(id);

            await ClangNotificationModule.logEvent("EVENT_NAME", eventData);
            console.log("success");
        } catch (error) {
            console.error(error)
        }
      };

  return (
    <Button
      title="Test 2"
      color="#841584"
      onPress={onPress}
    />
    
  );
};

export default NewTestButton;