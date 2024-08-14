[@react.component]
let make = () => {
  let (body, setBody) = React.useState(() => "No server connection!");
  let (isLoggedIn, setIsLoggedIn) = React.useState(() => false);

  React.useEffect0(() => {
    Js.Promise.(
      Fetch.fetchWithInit(
        "http://localhost:8000",
        Fetch.RequestInit.make(~method_=Get, ~credentials=Include, ()),
      )
      |> then_(Fetch.Response.text)
      |> then_(msg =>
           if (msg == "Logged in") {
             setBody(_ => msg);
             setIsLoggedIn(_ => true) |> resolve;
           } else {
             {
               setBody(_ => msg);

               setIsLoggedIn(_ => false);
             }
             |> resolve;
           }
         )
    )
    |> ignore;
    None;
  });

  let children =
    <div>
      <div> <Link href="signup"> {React.string("Sign up")} </Link> </div>
    </div>;

  isLoggedIn
    ? <Home> {React.string(body)} </Home>
    : <Home> {React.string(body)} children </Home>;
};
