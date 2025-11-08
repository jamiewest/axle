using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Axle.Migrations
{
    /// <inheritdoc />
    public partial class RenameIdentityTables : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_AspNetRoleClaims_AspNetRoles_RoleId",
                table: "AspNetRoleClaims");

            migrationBuilder.DropForeignKey(
                name: "FK_AspNetUserClaims_AspNetUsers_UserId",
                table: "AspNetUserClaims");

            migrationBuilder.DropForeignKey(
                name: "FK_AspNetUserLogins_AspNetUsers_UserId",
                table: "AspNetUserLogins");

            migrationBuilder.DropForeignKey(
                name: "FK_AspNetUserRoles_AspNetRoles_RoleId",
                table: "AspNetUserRoles");

            migrationBuilder.DropForeignKey(
                name: "FK_AspNetUserRoles_AspNetUsers_UserId",
                table: "AspNetUserRoles");

            migrationBuilder.DropForeignKey(
                name: "FK_AspNetUserTokens_AspNetUsers_UserId",
                table: "AspNetUserTokens");

            migrationBuilder.DropForeignKey(
                name: "FK_Nodes_AspNetUsers_CreatedById",
                table: "Nodes");

            migrationBuilder.DropForeignKey(
                name: "FK_Nodes_AspNetUsers_ModifiedById",
                table: "Nodes");

            migrationBuilder.DropForeignKey(
                name: "FK_RefreshTokens_AspNetUsers_UserId",
                table: "RefreshTokens");

            migrationBuilder.DropForeignKey(
                name: "FK_TenantUsers_AspNetUsers_UserId",
                table: "TenantUsers");

            migrationBuilder.DropPrimaryKey(
                name: "PK_AspNetUserTokens",
                table: "AspNetUserTokens");

            migrationBuilder.DropPrimaryKey(
                name: "PK_AspNetUsers",
                table: "AspNetUsers");

            migrationBuilder.DropPrimaryKey(
                name: "PK_AspNetUserRoles",
                table: "AspNetUserRoles");

            migrationBuilder.DropPrimaryKey(
                name: "PK_AspNetUserLogins",
                table: "AspNetUserLogins");

            migrationBuilder.DropPrimaryKey(
                name: "PK_AspNetUserClaims",
                table: "AspNetUserClaims");

            migrationBuilder.DropPrimaryKey(
                name: "PK_AspNetRoles",
                table: "AspNetRoles");

            migrationBuilder.DropPrimaryKey(
                name: "PK_AspNetRoleClaims",
                table: "AspNetRoleClaims");

            migrationBuilder.RenameTable(
                name: "AspNetUserTokens",
                newName: "NetUserTokens");

            migrationBuilder.RenameTable(
                name: "AspNetUsers",
                newName: "NetUsers");

            migrationBuilder.RenameTable(
                name: "AspNetUserRoles",
                newName: "NetUserRoles");

            migrationBuilder.RenameTable(
                name: "AspNetUserLogins",
                newName: "NetUserLogins");

            migrationBuilder.RenameTable(
                name: "AspNetUserClaims",
                newName: "NetUserClaims");

            migrationBuilder.RenameTable(
                name: "AspNetRoles",
                newName: "NetRoles");

            migrationBuilder.RenameTable(
                name: "AspNetRoleClaims",
                newName: "NetRoleClaims");

            migrationBuilder.RenameIndex(
                name: "IX_AspNetUserRoles_RoleId",
                table: "NetUserRoles",
                newName: "IX_NetUserRoles_RoleId");

            migrationBuilder.RenameIndex(
                name: "IX_AspNetUserLogins_UserId",
                table: "NetUserLogins",
                newName: "IX_NetUserLogins_UserId");

            migrationBuilder.RenameIndex(
                name: "IX_AspNetUserClaims_UserId",
                table: "NetUserClaims",
                newName: "IX_NetUserClaims_UserId");

            migrationBuilder.RenameIndex(
                name: "IX_AspNetRoleClaims_RoleId",
                table: "NetRoleClaims",
                newName: "IX_NetRoleClaims_RoleId");

            migrationBuilder.AddPrimaryKey(
                name: "PK_NetUserTokens",
                table: "NetUserTokens",
                columns: new[] { "UserId", "LoginProvider", "Name" });

            migrationBuilder.AddPrimaryKey(
                name: "PK_NetUsers",
                table: "NetUsers",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_NetUserRoles",
                table: "NetUserRoles",
                columns: new[] { "UserId", "RoleId" });

            migrationBuilder.AddPrimaryKey(
                name: "PK_NetUserLogins",
                table: "NetUserLogins",
                columns: new[] { "LoginProvider", "ProviderKey" });

            migrationBuilder.AddPrimaryKey(
                name: "PK_NetUserClaims",
                table: "NetUserClaims",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_NetRoles",
                table: "NetRoles",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_NetRoleClaims",
                table: "NetRoleClaims",
                column: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_NetRoleClaims_NetRoles_RoleId",
                table: "NetRoleClaims",
                column: "RoleId",
                principalTable: "NetRoles",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_NetUserClaims_NetUsers_UserId",
                table: "NetUserClaims",
                column: "UserId",
                principalTable: "NetUsers",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_NetUserLogins_NetUsers_UserId",
                table: "NetUserLogins",
                column: "UserId",
                principalTable: "NetUsers",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_NetUserRoles_NetRoles_RoleId",
                table: "NetUserRoles",
                column: "RoleId",
                principalTable: "NetRoles",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_NetUserRoles_NetUsers_UserId",
                table: "NetUserRoles",
                column: "UserId",
                principalTable: "NetUsers",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_NetUserTokens_NetUsers_UserId",
                table: "NetUserTokens",
                column: "UserId",
                principalTable: "NetUsers",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_Nodes_NetUsers_CreatedById",
                table: "Nodes",
                column: "CreatedById",
                principalTable: "NetUsers",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_Nodes_NetUsers_ModifiedById",
                table: "Nodes",
                column: "ModifiedById",
                principalTable: "NetUsers",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_RefreshTokens_NetUsers_UserId",
                table: "RefreshTokens",
                column: "UserId",
                principalTable: "NetUsers",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_TenantUsers_NetUsers_UserId",
                table: "TenantUsers",
                column: "UserId",
                principalTable: "NetUsers",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_NetRoleClaims_NetRoles_RoleId",
                table: "NetRoleClaims");

            migrationBuilder.DropForeignKey(
                name: "FK_NetUserClaims_NetUsers_UserId",
                table: "NetUserClaims");

            migrationBuilder.DropForeignKey(
                name: "FK_NetUserLogins_NetUsers_UserId",
                table: "NetUserLogins");

            migrationBuilder.DropForeignKey(
                name: "FK_NetUserRoles_NetRoles_RoleId",
                table: "NetUserRoles");

            migrationBuilder.DropForeignKey(
                name: "FK_NetUserRoles_NetUsers_UserId",
                table: "NetUserRoles");

            migrationBuilder.DropForeignKey(
                name: "FK_NetUserTokens_NetUsers_UserId",
                table: "NetUserTokens");

            migrationBuilder.DropForeignKey(
                name: "FK_Nodes_NetUsers_CreatedById",
                table: "Nodes");

            migrationBuilder.DropForeignKey(
                name: "FK_Nodes_NetUsers_ModifiedById",
                table: "Nodes");

            migrationBuilder.DropForeignKey(
                name: "FK_RefreshTokens_NetUsers_UserId",
                table: "RefreshTokens");

            migrationBuilder.DropForeignKey(
                name: "FK_TenantUsers_NetUsers_UserId",
                table: "TenantUsers");

            migrationBuilder.DropPrimaryKey(
                name: "PK_NetUserTokens",
                table: "NetUserTokens");

            migrationBuilder.DropPrimaryKey(
                name: "PK_NetUsers",
                table: "NetUsers");

            migrationBuilder.DropPrimaryKey(
                name: "PK_NetUserRoles",
                table: "NetUserRoles");

            migrationBuilder.DropPrimaryKey(
                name: "PK_NetUserLogins",
                table: "NetUserLogins");

            migrationBuilder.DropPrimaryKey(
                name: "PK_NetUserClaims",
                table: "NetUserClaims");

            migrationBuilder.DropPrimaryKey(
                name: "PK_NetRoles",
                table: "NetRoles");

            migrationBuilder.DropPrimaryKey(
                name: "PK_NetRoleClaims",
                table: "NetRoleClaims");

            migrationBuilder.RenameTable(
                name: "NetUserTokens",
                newName: "AspNetUserTokens");

            migrationBuilder.RenameTable(
                name: "NetUsers",
                newName: "AspNetUsers");

            migrationBuilder.RenameTable(
                name: "NetUserRoles",
                newName: "AspNetUserRoles");

            migrationBuilder.RenameTable(
                name: "NetUserLogins",
                newName: "AspNetUserLogins");

            migrationBuilder.RenameTable(
                name: "NetUserClaims",
                newName: "AspNetUserClaims");

            migrationBuilder.RenameTable(
                name: "NetRoles",
                newName: "AspNetRoles");

            migrationBuilder.RenameTable(
                name: "NetRoleClaims",
                newName: "AspNetRoleClaims");

            migrationBuilder.RenameIndex(
                name: "IX_NetUserRoles_RoleId",
                table: "AspNetUserRoles",
                newName: "IX_AspNetUserRoles_RoleId");

            migrationBuilder.RenameIndex(
                name: "IX_NetUserLogins_UserId",
                table: "AspNetUserLogins",
                newName: "IX_AspNetUserLogins_UserId");

            migrationBuilder.RenameIndex(
                name: "IX_NetUserClaims_UserId",
                table: "AspNetUserClaims",
                newName: "IX_AspNetUserClaims_UserId");

            migrationBuilder.RenameIndex(
                name: "IX_NetRoleClaims_RoleId",
                table: "AspNetRoleClaims",
                newName: "IX_AspNetRoleClaims_RoleId");

            migrationBuilder.AddPrimaryKey(
                name: "PK_AspNetUserTokens",
                table: "AspNetUserTokens",
                columns: new[] { "UserId", "LoginProvider", "Name" });

            migrationBuilder.AddPrimaryKey(
                name: "PK_AspNetUsers",
                table: "AspNetUsers",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_AspNetUserRoles",
                table: "AspNetUserRoles",
                columns: new[] { "UserId", "RoleId" });

            migrationBuilder.AddPrimaryKey(
                name: "PK_AspNetUserLogins",
                table: "AspNetUserLogins",
                columns: new[] { "LoginProvider", "ProviderKey" });

            migrationBuilder.AddPrimaryKey(
                name: "PK_AspNetUserClaims",
                table: "AspNetUserClaims",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_AspNetRoles",
                table: "AspNetRoles",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_AspNetRoleClaims",
                table: "AspNetRoleClaims",
                column: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_AspNetRoleClaims_AspNetRoles_RoleId",
                table: "AspNetRoleClaims",
                column: "RoleId",
                principalTable: "AspNetRoles",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_AspNetUserClaims_AspNetUsers_UserId",
                table: "AspNetUserClaims",
                column: "UserId",
                principalTable: "AspNetUsers",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_AspNetUserLogins_AspNetUsers_UserId",
                table: "AspNetUserLogins",
                column: "UserId",
                principalTable: "AspNetUsers",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_AspNetUserRoles_AspNetRoles_RoleId",
                table: "AspNetUserRoles",
                column: "RoleId",
                principalTable: "AspNetRoles",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_AspNetUserRoles_AspNetUsers_UserId",
                table: "AspNetUserRoles",
                column: "UserId",
                principalTable: "AspNetUsers",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_AspNetUserTokens_AspNetUsers_UserId",
                table: "AspNetUserTokens",
                column: "UserId",
                principalTable: "AspNetUsers",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_Nodes_AspNetUsers_CreatedById",
                table: "Nodes",
                column: "CreatedById",
                principalTable: "AspNetUsers",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_Nodes_AspNetUsers_ModifiedById",
                table: "Nodes",
                column: "ModifiedById",
                principalTable: "AspNetUsers",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_RefreshTokens_AspNetUsers_UserId",
                table: "RefreshTokens",
                column: "UserId",
                principalTable: "AspNetUsers",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_TenantUsers_AspNetUsers_UserId",
                table: "TenantUsers",
                column: "UserId",
                principalTable: "AspNetUsers",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
