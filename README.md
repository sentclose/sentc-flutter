# Sentc light sdk

from sentclose.

Sentc is an easy to use end-to-end encryption sdk. It can be used for any kind of data.

## Example

````dart
demo() async {
  //init the client
  await Sentc.init(appToken: "5zMb6zs3dEM62n+FxjBilFPp+j9e7YUFA+7pi6Hi");

  //register a user
  await Sentc.register("userIdentifier", "password");

  //log in a user
  final user = await Sentc.login("userIdentifier", "password");

  //create a group
  final groupId = await user.createGroup();

  //load a group. returned a group obj for every user.
  final group = await user.getGroup(groupId);

  //invite another user to the group. Not here in the example because we only got one user so far
  // await group.inviteAuto("other user id");

  //delete a group
  await group.deleteGroup();

  //delete a user
  await user.deleteUser("password");
}
````