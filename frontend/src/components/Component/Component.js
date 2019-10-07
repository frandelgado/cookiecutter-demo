import React from 'react';
import './Component.scss';

class Component extends React.Component {
  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {
    return <h2 className="component">Sample Component</h2>;
  }
}

export default Component;
