[@react.component]
let make = () => {
  let (body, setBody) = React.useState(() => "No server connection!");

  Js.Promise.(
    Fetch.fetchWithInit(
      "http://localhost:8000",
      Fetch.RequestInit.make(~method_=Get, ()),
    )
    |> then_(Fetch.Response.text)
    |> then_(msg => setBody(_ => msg) |> resolve)
  )
  |> ignore;

  let children =
    <div>
      <div> <Link href="signup"> {React.string("Sign up")} </Link> </div>
    </div>;

  <Home> {React.string(body)} children </Home>;
};
