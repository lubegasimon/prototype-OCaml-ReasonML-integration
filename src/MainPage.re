let children =
  <div>
    <h3> {React.string("Welcome to expense tracker!")} </h3>
    <div> <Link href="signup"> {React.string("Sign up")} </Link> </div>
  </div>;

[@react.component]
let make = () => {
  <Home> children </Home>;
};
