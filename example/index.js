exports.handler = async (event, context) => {
  console.log("I am a Lambda function")
  console.log("Event: ")
  console.log(JSON.stringify(event, null, 2))
  console.log("Context: ")
  console.log(JSON.stringify(context, null, 2))
  return true;
}
