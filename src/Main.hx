package;

import tink.Cli;
import tink.cli.*;

class Main {
    public static function main() {
        Cli.process(Sys.args(), new Unpacker()).handle(Cli.exit);
    }
}
