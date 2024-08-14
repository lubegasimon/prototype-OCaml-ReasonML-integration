[@react.component]
let make = () => {
  let (username, setUsername) = React.useState(() => "");
  let (password, setPassword) = React.useState(() => "");
  let (error, setError) = React.useState(() => "");

  let handleSubmit = event => {
    /* preventing browser's default behavior of form submission a reloading the
       page, allow to handle form submission with custom logic */
    React.Event.Form.preventDefault(event);

    /* preparing the form data to be sent to the server */
    // create an empty dictionary
    let formData = Js.Dict.empty();
    // populate the dictionary
    Js.Dict.set(formData, "username", username);
    Js.Dict.set(formData, "password", password);

    Js.Promise.
      /* Initiate a fetch request to the server using the provided url with other details */
      (
        Fetch.fetchWithInit(
          "http://localhost:8000/signup",
          Fetch.RequestInit.make(
            ~method_=Post,
            ~body=
              Fetch.BodyInit.make(
                /* serializing form data into URL-encoded string which is set as request
                   body */
                Js.Dict.entries(formData)
                |> Js.Array.map(~f=((key, value)) => {key ++ "=" ++ value})
                |> Js.Array.join(~sep="&"),
              ),
            // specifies the type of content being sent to the server
            ~headers=
              Fetch.HeadersInit.make({"Content-Type": "multipart/form-data"}),
            ~credentials=Include,
            (),
          ),
        )
        /* Handling the server's response */
        |> then_(response =>
             if (Fetch.Response.redirected(response)) {
               Js.Console.log("Redirecting ... \n");
               ReasonReactRouter.push("/") |> resolve;
             } else {
               response
               |> Fetch.Response.text
               |> then_(text =>
                    setError(_ => text)
                    |> resolve
                    |> catch(error => {
                         Js.Console.log("Error: " ++ Js.String.make(error))
                         |> resolve
                       })
                  );
             }
           )
        // discard the result of the promise chain, as it is not needed beyond state update
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
      {error != ""
         ? <div> {React.string("Error: " ++ error)} </div> : React.null}
    </form>
  </div>;
};
