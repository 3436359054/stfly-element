import { makeInstaller } from "@stfly-element/utils";
import components from "./components";
import '@stfly-element/theme/index.css';

const installer = makeInstaller(components);

export * from "../components";
export default installer;