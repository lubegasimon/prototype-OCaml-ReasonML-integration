let handleClick = event =>
  if (!React.Event.Mouse.defaultPrevented(event)) {
    React.Event.Mouse.preventDefault(event);
    ReasonReactRouter.push("signup");
  };

[@react.component]
let make = () => {
  <div>
    <h3> {React.string("Welcome to expense tracker!")} </h3>
    <div>
      <a href="signup" onClick={e => handleClick(e)}>
        {React.string("Sign up")}
      </a>
    </div>
  </div>;
};
