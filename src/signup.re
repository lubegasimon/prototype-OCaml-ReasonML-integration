[@react.component]
let make = () => {
  let (username, setUsername) = React.useState(() => "");
  let (password, setPassword) = React.useState(() => "");
  let (message, setMessage) = React.useState(() => "");

  let handleSubmit = event => {
    React.Event.Form.preventDefault(event);

    let formData = Js.Dict.empty();
    Js.Dict.set(formData, "username", username);
    Js.Dict.set(formData, "password", password);

    Js.Promise.(
      Fetch.fetchWithInit(
        "http://localhost:8000/signup",
        Fetch.RequestInit.make(
          ~method_=Post,
          ~body=
            Fetch.BodyInit.make(
              Js.Dict.entries(formData)
              |> Js.Array.map(~f=((key, value)) => {key ++ "=" ++ value})
              |> Js.Array.join(~sep="&"),
            ),
          ~headers=
            Fetch.HeadersInit.make({"Content-Type": "multipart/form-data"}),
          (),
        ),
      )
      |> then_(Fetch.Response.text)
      |> then_(text =>
           setMessage(_ => text)
           |> resolve
           |> catch(error => {
                Js.Console.log("Error: " ++ Js.String.make(error)) |> resolve
              })
         )
      |> ignore
    );
  };

  <div>
    <form action="signup" method="post" onSubmit=handleSubmit>
      <label>
        {React.string("Username: ")}
        <input
          className="username"
          type_="text"
          autoFocus=true
          placeholder="username"
          value=username
          onChange={event =>
            setUsername(React.Event.Form.target(event)##value)
          }
        />
      </label>
      <br />
      <br />
      <label>
        {React.string("Password: ")}
        <input
          className="password"
          type_="text"
          autoFocus=false
          placeholder="password"
          value=password
          onChange={event =>
            setPassword(React.Event.Form.target(event)##value)
          }
        />
      </label>
      <br />
      <br />
      <button type_="submit"> {React.string("Sign up")} </button>
    </form>
    // TODO: message should be in a component on another page after redirection
    {message != "" ? <div> {React.string(message)} </div> : React.null}
  </div>;
};
