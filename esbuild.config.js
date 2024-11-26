import * as esbuild from "esbuild";
import * as fs from "fs";

const ctx = await esbuild.context({
  entryPoints: ["app/javascript/*.js"],
  bundle: true,
  sourcemap: true,
  format: "esm",
  outdir: "app/assets/builds",
  publicPath: "/assets",
  write: false,
  loader: {
    ".css": "css",
  },
  plugins: [
    {
      name: "css-output",
      setup(build) {
        build.onEnd(async (result) => {
          try {
            if (!result.outputFiles) return;
            // Collect all CSS content
            let cssContent = "";
            const cssFiles = result.outputFiles.filter((file) =>
              file.path.endsWith(".css")
            );
            cssFiles.forEach((file) => {
              cssContent += Buffer.from(file.contents).toString("utf-8") + "\n";
            });

            // Write consolidated CSS file
            await fs.promises.writeFile(
              "app/assets/builds/js-styles.css",
              cssContent
            );
            console.log("✓ js-styles.css written successfully");

            // Write all other output files
            for (const file of result.outputFiles) {
              const filepath = file.path;
              await fs.promises.writeFile(filepath, file.contents);
              console.log(
                `✓ ${filepath.split("/").pop()} written successfully`
              );
            }
          } catch (error) {
            console.error("Failed to process files:", error);
          }
        });
      },
    },
  ],
});

if (process.argv.includes("--watch")) {
  await ctx.watch();
} else {
  await ctx.rebuild();
  await ctx.dispose();
}
