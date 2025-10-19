import * as React from "react";

export const Button = ({ children }: { children: React.ReactNode }) => {
  return (
    <button className="btn btn-primary">
      {children}
    </button>
  );
};
