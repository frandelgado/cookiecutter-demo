import { combineReducers } from 'redux';

import sampleReducer from './modules/sample/reducer';

const rootReducer = combineReducers({
  sample: sampleReducer,
});

export default rootReducer;
