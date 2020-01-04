package;

import format.png.Data;
import format.png.Reader;
import format.png.Writer;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.Path;
import spine.Texture;
import spine.TextureAtlas;
import sys.FileSystem;
import sys.io.File;
import tink.cli.*;

using format.png.Tools;

@:alias(false)
class Unpacker {
    public var gdx = true;
    public var foldername = 'unpacked';

    @:defaultCommand
    public function run( rest: Rest<String> ) {
        if (rest.length < 1) {
            Sys.println('usage: node atlas-unpacker.js SOURCE');
            return;
        }

        final filename = rest[0];
        final inputPath = Path.directory(filename);
        final atlasData = File.getContent(filename);
        var pngData: Data;
        // TODO (DK) support multiple images?
        final atlas = new TextureAtlas(atlasData, path -> {
            final texturePath = Path.join([inputPath, path]);
            final textureBytes = File.getBytes(texturePath);
            pngData = new Reader(new BytesInput(textureBytes)).read();
            return new FakeTexture(64, 64);
        });

        final bgra = pngData.extract32();
        final imgw = pngData.getHeader().width;

        for (r in atlas.regions) {
            final outpath = Path.join([inputPath, foldername, '${r.name}.png']); // TODO (DK) .png optional?

            if (r.originalWidth != r.width || r.originalHeight != r.height) {
                Sys.println('resized regions are not yet supported');
                continue;
            }

            final outsize = r.width * r.height * 4;
            final outbytes = Bytes.alloc(outsize);
            final rw = r.rotate ? r.height : r.width;
            final rh = r.rotate ? r.width : r.height;

            for (y in 0...rh) {
                final from = (y + r.y) * imgw * 4 + r.x * 4;
                outbytes.blit(y * rw * 4, bgra, from, rw * 4);
            }

            final outdata = Tools.build32BGRA(rw, rh, outbytes);
            FileSystem.createDirectory(Path.join([inputPath, foldername]));
            final outStream = File.write(outpath);
            new Writer(outStream).write(outdata);
            outStream.close();
        }
    }

    public function new() {
    }
}
