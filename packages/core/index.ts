import { library } from "@fortawesome/fontawesome-svg-core";
import { fas } from "@fortawesome/free-solid-svg-icons";
import { makeInstaller } from "@stfly-element/utils";
import components from "./components";
import '@stfly-element/theme/index.css';

library.add(fas);
const installer = makeInstaller(components);

export * from "../components";
export default installer;