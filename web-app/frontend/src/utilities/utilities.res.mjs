// Generated by ReScript, PLEASE EDIT WITH CARE


async function makeRequest(url) {
  var response = await fetch(url);
  var json = await response.json();
  console.log(json);
}

function connectToBackend() {
  console.log("triggered");
}

export {
  makeRequest ,
  connectToBackend ,
}
/* No side effect */
