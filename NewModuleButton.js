import React from 'react';
import { NativeModules, Button } from 'react-native';

const { ClangNotificationModule } = NativeModules;

const NewModuleButton = () => {
    const onPress = () => {
        ClangNotificationModule.test("Adam", (greeting) => {
            console.log(greeting);
        });
      };

  return (
    <Button
      title="Test 1"
      color="#841584"
      onPress={onPress}
    />
    
  );
};

export default NewModuleButton;